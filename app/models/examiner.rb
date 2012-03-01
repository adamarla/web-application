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

  # [:all] ~> [:admin]
  # [:num_contested] ~> [:student]
  #attr_accessible :num_contested

  def name 
    return "#{self.first_name} #{self.last_name} (#{self.account.username})"
  end 

  def name=(name)
    split = name.split(' ', 2)
    self.first_name = split.first
    self.last_name = split.last
  end

  def self.pending_quizzes
    pending = GradedResponse.ungraded.map(&:q_selection_id).uniq
    quiz_ids = QSelection.where(:id => pending).map(&:quiz_id).uniq
    @quizzes = Quiz.where :id => quiz_ids
  end

  def self.pages( quiz = nil, type = :pending ) # other option is :graded
    # Find all the pages from passed quiz assigned to this particular examiner
    return [] if quiz.nil?

    responses = GradedResponse.in_quiz(quiz.id)
    responses = (type == :pending) ? responses.ungraded : responses.where('grade_id IS NOT NULL')

    @pages = QSelection.where(:id => responses.map(&:q_selection_id).uniq).map(&:page).uniq
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
    The prep work an examiner needs to do before starting to grade is, really, 
    the same for each new work-set. So, don't make the examiner spend that time
    over just a few scans

    In other words, if there are 10 scans and 10 examiners, then it makes more sense
    to assign 5 scans each to two examiners than to assign one scan each to the 
    10 examiners 
=end
    examiners = Examiner.order(:last_workset_on)
    n_examiners = examiners.count
    start_pt = 0
    scans = GradedResponse.where('examiner_id IS NULL').where('scan IS NOT NULL')
    quiz_ids = scans.map(&:q_selection).map(&:quiz).map(&:id).uniq
    per_quiz_limit = 20

    Quiz.where(:id => quiz_ids).each_with_index do |quiz, index|
      last_page = QSelection.where(:quiz_id => quiz.id).order(:page).select(:page).last.page
      [*1..last_page].each do |page|
        page_scans = scans & GradedResponse.in_quiz(quiz.id).on_page(page)
        n_scans = page_scans.count 
        next if n_scans == 0 # no scans for this page of this quiz 

        # Try and allocate 'per_quiz_limit' pages/quiz to each examiner
        n_reqd = (n_scans / per_quiz_limit) + 1

        if n_reqd > n_examiners # too bad ... more work for everyone 
          assign_to = [*0...n_examiners]
        else 
          assign_to = circular_slice [*0...n_examiners], start_pt, n_reqd
          start_pt = n_reqd % n_examiners # for next time 
        end

        n_assignees = assign_to.count
        j = 0 

        page_scans.each_with_index do |p,index|
          j = (j < n_assignees) ? j : 0
          examiner_id = assign_to[j]
          puts "[quiz, page, examiner] = [#{quiz.id}, #{page}, #{examiner_id}]"
          # p.update_attribute :examiner_id, examiner_id
          j += 1
        end

        # Update last_workset_on for examiners in assign_to 
        # right_now = Time.now 
        # Examiners.where(:id => assign_to).each do |e|
        #   e.update_attribute :last_workset_on = right_now 

      end # of page 
    end # of Quiz do...

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

        db_record = GradedResponse.in_quiz(quiz).on_page(page).of_student(student).first
        if db_record
          db_record.update_attribute :scan, entry
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

end # of class
