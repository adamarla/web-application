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

  def name=(name)
    split = name.split(' ', 2)
    self.first_name = split.first
    self.last_name = split.last
  end

  def pending_quizzes
    pending = GradedResponse.with_scan.assigned_to(self.id).ungraded.map(&:q_selection_id).uniq
    quiz_ids = QSelection.where(:id => pending).map(&:quiz_id).uniq
    @quizzes = Quiz.where :id => quiz_ids
  end

  def block_db_slots
    slots = []
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['create_question']}" 

    [*1...6].each do |index|
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
      slots.delete s unless q.save
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
    scans = GradedResponse.with_scan.unassigned
    quiz_ids = scans.map(&:q_selection).map(&:quiz_id).uniq
    limit = 20
    num_examiners = Examiner.count

    quiz_ids.each do |qid|
      quiz = Quiz.find qid 
      num_pages = quiz.num_pages

      [*1..num_pages].each do |page|
        examiner_ids = Examiner.order(:last_workset_on).map(&:id) # allocation order
        responses_on_this_pg = scans & GradedResponse.in_quiz(qid).on_page(page)
        uniq_pg_scans = responses_on_this_pg.map(&:scan).uniq
        uniq_count = uniq_pg_scans.count

        # Estimate the number of examiners needed to process a reasonable chunk
        # of work ( = 20 scans of one page of one quiz )
        num_reqd_examiners = (uniq_count / limit) + 1
        num_reqd_examiners = (num_reqd_examiners > num_examiners) ? num_examiners : num_reqd_examiners
        per_examiner = uniq_count / num_reqd_examiners
        start = 0 # start index
        allocate_to = examiner_ids.slice 0, num_reqd_examiners

        # Now, start allocating 
        allocate_to.each do |allottee|
          allot = uniq_pg_scans.slice start, per_examiner
          start += per_examiner
          pick = responses_on_this_pg.select {|a| allot.include? a.scan}
          examiner = Examiner.find allottee

          pick.each do |r|
            r.update_attribute :examiner_id, allottee
          end 
          examiner.update_attribute :last_workset_on, Time.now
        end
      end # num_pages
    end # quiz_ids

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
    unless manifest.nil?
      manifest[:image].each_with_index do |entry, index|
        file = entry[:id]
        image = file.split('.').first # get rid of the jpg extension 
        quiz, testpaper, student, page = image.split('-').map(&:to_i)

        # There can be > 1 question on a page and hence > 1 GradedResponses that
        # share the same scan 
        db_records = GradedResponse.in_quiz(quiz).on_page(page).of_student(student)
        unless db_records.empty?
          db_records.each do |x|
            x.update_attribute :scan, image
          end
        else
          name = Student.find(student).name
          failures.push({:name => name, :id => page}) 
          # 'name, id' pairs are standard keys in our standard JSON response
        end 
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

end # of class
