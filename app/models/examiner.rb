# == Schema Information
#
# Table name: examiners
#
#  id              :integer         not null, primary key
#  disputed        :integer         default(0)
#  created_at      :datetime
#  updated_at      :datetime
#  is_admin        :boolean         default(FALSE)
#  first_name      :string(30)
#  last_name       :string(30)
#  last_workset_on :datetime
#

class Examiner < ActiveRecord::Base
  has_one :account, :as => :loggable
  has_many :graded_responses

  # [:all] ~> [:admin]
  # [:disputed] ~> [:student]
  #attr_accessible :disputed

  def name 
    return self.last_name.nil? ? self.first_name : "#{self.first_name} #{self.last_name}"
  end 

  def name=(name)
    split = name.split
    last = split.count - 1
    self.first_name = split.first.humanize

    if last > 0
      middle = split[1...last].map{ |m| m.humanize[0] }.join('.')
      self.last_name = middle.empty? ? "#{split.last.humanize}" : "#{middle} #{split.last.humanize}"
    end
  end

  def block_db_slots( n = 6 )
    slots = []
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['create_question']}" 
    
    [*1..n].each do |index|
      response = SavonClient.request :wsdl, :createQuestion do
        soap.body = "#{self.id}"
      end
      manifest = response[:create_question_response][:manifest]
      unless manifest.nil?
        root = manifest[:root] 
        uid = root.split('/').last
        slots << uid
      end
      sleep 1.0/2 # sleep for 500ms
    end # of looping

    # Now, make the DB entries for the slots that were created 
    slots.each do |s|
      q = Question.new :uid => s, :examiner_id => self.id
      slots.delete s unless q.save # return only those slots that got created
    end
    return slots
  end

  def pending_workload
    return GradedResponse.where(:examiner_id => self.id).where('grade_id IS NULL').count
  end

  def self.distribute_work
=begin
  Distribution algorithm
  -----------------------
  For each quiz, find the available scans that are as yet unassigned. Note that there
  is one scan per page AND there can be >1 graded responses per page ( and therefore, scan ) 

  Distribute the scans equally amongst the available examiners. As a result, all 
  graded responses on the scan will get assigned to the examiner who gets the scan

=end
    self.distribute_standalone
    self.distribute_multipart
    self.distribute_suggestions
  end

  def self.receive_scans
    failures = []

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['receive_scans']}" 
    response = SavonClient.request :wsdl, :receiveScans do
      soap.body = {}
    end
    
    # manifest => { :root => ..., :image => [{:id => '1-2-3.jpg'}, {:id => 'x-y-z.jpg'} ...] }
    manifest = response[:receive_scans_response][:manifest]

    # Scan ID to send via Savon : scanId = quizId-testpaperId-studentId-page#.jpg
    unless manifest[:image].nil?
      manifest[:image].each_with_index do |entry, index|
        id = entry[:id]
        next if id == "SAVON_BUG_SKIP"
        file = entry[:value]
        quiz, testpaper, student, page = id.split('-').map(&:to_i)

        unless quiz == 0 # => standard response scan  
          # There can be > 1 question on a page and hence > 1 GradedResponses that
          # share the same scan 
          db_records = GradedResponse.in_quiz(quiz).of_student(student).on_page(page)
          unless db_records.empty?
            db_records.each do |x|
              x.update_attribute :scan, file
            end

            ## :received field of AnswerSheets is updated when the first 
            ## query to AnswerSheet.received? is made 

          else
            name = Student.find(student).name
            failures.push({:name => name, :id => page}) 
            # 'name, id' pairs are standard keys in our standard JSON response
          end
        else # => suggestion scan 
          teacher = student     #in this case the "student" carries teacher's     
          signature = testpaper #id and "testpaper" carries scan file signature     
          suggestion = Suggestion.new :teacher_id => teacher, :signature => signature
          suggestion.save
        end # of unless      
      end # of do ..
      self.distribute_work #####   THE BIG KAHUNA   #######
    end # of unless
    return failures
  end

  private

    def self.distribute_standalone
      unassigned = GradedResponse.unassigned.with_scan.standalone
      testpaper_ids = unassigned.map(&:testpaper_id).uniq
      allottees = Examiner.where(:is_admin => true)  ## for now 
      limit = 20

      testpaper_ids.each do |tid|
        in_testpaper = unassigned.select{ |m| m.testpaper_id == tid }
        pages = in_testpaper.map(&:page?).uniq

        pages.each do |pg|
          on_page = in_testpaper.select{ |m| m.page == pg }
          student_ids = on_page.map(&:student_id).uniq
          nstudents = student_ids.count 

          examiners = allottees.order{ |m,n| m.last_workset_on.nil? || m.last_workset_on <=> n.last_workset_on }
          reqd = (nstudents / limit ) + 1
          reqd = (reqd > examiners.count) ? examiners.count : reqd
          workload = (nstudents / reqd) + 1

          j = 0 
          student_ids.each_slice(workload).each do |id_slice|
            e = examiners[j]

            id_slice.each do |sid| # responses of a given student, on given page, in given testpaper
              responses = on_page.select{ |m| m.student_id == sid }
              responses.each do |r|
                r.update_attribute :examiner_id, e.id
              end 
            end
            e.update_attribute :last_workset_on, Time.now
            j = j + 1  # next examiner
          end # of students
        end # of pages
      end # of testpapers
    end # of method 

    def self.distribute_multipart
      # This is a private method. So, it can't be called willy-nilly
      # It is called, however, imeediately after distribute_standalone - by
      # which time all the standalone questions have been distributed. So, 
      # the only ones left are the multipart ones

      unassigned = GradedResponse.unassigned.with_scan

      # The unassigned responses are for some questions and from some students
      # And for each student, therefore, we ensure that scans are available for 
      # each sub-part of each question under consideration. If scans are available
      # for only some parts and not others, then we skip assigning that whole question
      # for grading. We will wait until all scans are available 

      student_ids = unassigned.map(&:student_id).uniq
      student_ids.each do |s|
        responses = GradedResponse.unassigned.with_scan.of_student(s)
        question_ids = responses.map{ |m| m.q_selection.question_id }.uniq 

        question_ids.each do |q|
          # Remember: one graded response per student for each subpart 
          with_scan = responses.to_db_question(q)
          question = Question.find q
          nparts = question.num_parts?
          next if with_scan.count != nparts

          grader = Examiner.where(:is_admin => true).order(:last_workset_on).first # for now
          with_scan.each do |p|
            p.update_attribute :examiner_id, grader.id
          end
          grader.update_attribute :last_workset_on, Time.now
        end # questions loop 
      end # student loop

    end # of method
    
    def self.distribute_suggestions
      # last_workset_on is updated ONLY when graded_responses are assigned. So, if you 
      # aren't grading, then you must typeset some questions 
      e_ids = Examiner.where(:is_admin => true).order(:last_workset_on).map(&:id)
      n = e_ids.count

      Suggestion.unassigned.each_with_index do |m, j|
        m.update_attribute :examiner_id, e_ids[j % n]
      end
    end #  of method

end # of class
