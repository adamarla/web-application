# == Schema Information
#
# Table name: examiners
#
#  id              :integer         not null, primary key
#  num_contested   :integer         default(0)
#  created_at      :datetime
#  updated_at      :datetime
#  is_admin        :boolean         default(FALSE)
#  first_name      :string(255)
#  last_name       :string(255)
#  last_workset_on :datetime
#

class Examiner < ActiveRecord::Base
  has_one :account, :as => :loggable
  has_many :graded_responses
  before_save :humanize_name

  # [:all] ~> [:admin]
  # [:num_contested] ~> [:student]
  #attr_accessible :num_contested

  def name 
    return "#{self.last_name}, #{self.first_name}"
  end 

  def abbreviated_name
    return "#{self.first_name} #{self.last_name[0]}."
  end

  def name=(name)
    split = name.split
    self.first_name = split.first
    self.last_name = split.last
  end

  def pending_quizzes
    pending = GradedResponse.with_scan.assigned_to(self.id).ungraded.map(&:q_selection_id).uniq
    quiz_ids = QSelection.where(:id => pending).map(&:quiz_id).uniq
    @quizzes = Quiz.where :id => quiz_ids
  end

  def block_db_slots( n = 6 )
    slots = []
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['create_question']}" 
    
    [*1..n].each do |index|
      response = SavonClient.request :wsdl, :create_question do
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

  def suggestions
    Suggestion.assigned_to self.id
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
        file = entry[:id]
        next if file == "SAVON_BUG_SKIP"
        image = file.split('.').first # get rid of the jpg extension 
        quiz, testpaper, student, page = image.split('-').map(&:to_i)

        unless quiz == 0 # => standard response scan  
          # There can be > 1 question on a page and hence > 1 GradedResponses that
          # share the same scan 
          db_records = GradedResponse.in_quiz(quiz).of_student(student).on_page(page)
          unless db_records.empty?
            db_records.each do |x|
              x.update_attribute :scan, image
            end
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
      self.distribute_work 
    end # of unless
    return failures
  end

  private
    
    def humanize_name
      self.first_name = self.first_name.humanize
      self.last_name = self.last_name.humanize
    end 

    def self.distribute_standalone
      unassigned = GradedResponse.unassigned.with_scan.standalone
      limit = 15

      scans = unassigned.sort{ |m,n| m.scan <=> n.scan }.map(&:scan).uniq
      scans.each do |s|
        quiz, testpaper, student, page = s.split('-').map(&:to_i)
        todo = unassigned & GradedResponse.unassigned.where(:testpaper_id => testpaper).on_page(page)
        next if todo.empty?

        student_ids = todo.map(&:student_id).uniq
        nstudents = student_ids.count # students whose scans for page N in testpaper M have come in
        examiners = Examiner.order(:last_workset_on)
        nexaminers = examiners.count
        reqd = (nstudents/limit) + 1
        reqd = (reqd > nexaminers) ? nexaminers : reqd
        workload = (nstudents / reqd) + 1
        grader_ids = examiners.map(&:id).slice(0, reqd) # use these graders

        start = 0 
        grader_ids.each do |g|
          pick = student_ids.slice(start, workload)
          start += workload
          todo.select{ |m| pick.include? m.student_id }.each do |t|
            t.update_attribute :examiner_id, g
          end
        end #grader_ids 

        unassigned = GradedResponse.unassigned.with_scan.standalone
        break if unassigned.empty?
      end #scans 
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
          with_scan = responses & GradedResponse.unassigned.with_scan.to_question(q)
          question = Question.find q
          nparts = question.num_parts?
          next if with_scan.count != nparts

          grader = Examiner.order(:last_workset_on).first
          with_scan.each do |p|
            p.update_attribute :examiner_id, grader.id
          end
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
