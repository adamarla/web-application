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
    The prep work an examiner needs to do before starting to grade is, really, 
    the same for each new work-set. So, don't make the examiner spend that time
    over just a few scans

    In other words, if there are 10 scans and 10 examiners, then it makes more sense
    to assign 5 scans each to two examiners than to assign one scan each to the 
    10 examiners 
    examiners = Examiner.order(:last_workset_on)
    n_examiners = examiners.count
    start_pt = 0
=end
    scans = GradedResponse.with_scan.unassigned
    quiz_ids = scans.map(&:q_selection).map(&:quiz_id).uniq
    limit = 20

    Quiz.where(:id => quiz_ids).each_with_index do |quiz, index|
      last_page = quiz.num_pages 
      examiners = Examiner.order(:last_workset_on)
      n_examiners = examiners.count

      [*1..last_page].each do |page|
        on_this_pg = scans & GradedResponse.in_quiz(quiz.id).on_page(page).order(:student_id)
        next if on_this_pg.count == 0 

        students = on_this_page.map(&:student_id).uniq
        n_students = students.count 
        n_reqd_examiners = (n_students / limit) + 1
        graders = (n_reqd_examiners > n_examiners) ? examiners : examiners.slice(0, n_reqd_examiners)
        per_grader = (students/graders.count)

        remaining = students

        graders.each do |g|
          while (remaining.empty? == false)
            pick = remaining.slice(0, per_grader)
            remaining = remaining - pick
            pick.each do |id|
              on_this_page.where(:student_id => id).each do |response|
                response.update_attribute :examiner_id, g.id
              end #1
            end # pick
            g.update_attribute :last_workset_on, Time.now
          end # while
        end # graders

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
