# == Schema Information
#
# Table name: examiners
#
#  id              :integer         not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  is_admin        :boolean         default(FALSE)
#  first_name      :string(30)
#  last_name       :string(30)
#  last_workset_on :datetime
#  n_assigned      :integer         default(0)
#  n_graded        :integer         default(0)
#  live            :boolean         default(FALSE)
#

include GeneralQueries

class Examiner < ActiveRecord::Base
  has_one :account, as: :loggable
  has_many :graded_responses
  has_many :suggestions

  has_many :apprenticeships, dependent: :destroy

  # [:all] ~> [:admin]
  # [:disputed] ~> [:student]
  #attr_accessible :disputed

  def self.available
    select{ |m| m.account.active }
  end

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
      slots << manifest[:root] unless manifest.nil?

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

  def self.distribute_scans
    pnd = GradedResponse.unassigned.with_scan
    exams = pnd.map(&:worksheet).uniq.map(&:exam).uniq 
    by = exams.map(&:quiz).uniq.map(&:teacher).select{ |t| !t.online }

    examiners = Examiner.select{ |e| e.account.active }.sort{ |m,n| m.updated_at <=> n.updated_at }
    n_examiners = examiners.count
    used = [] # to track examiners to whom an e-mail must be sent

    pnd.map(&:q_selection_id).uniq.each do |q|
      pending = pnd.where(q_selection_id: q) # responses to specific question in specific quiz  
      students = pending.map(&:student_id).uniq
      limit = (students.count / n_examiners)
      limit = limit > 20 ? limit : 20

      students.each_slice(limit).each do |j|
        assignee = examiners.shift # pop from front 
        used.push assignee.id

        work = pending.where(student_id: j)
        work.map{ |m| m.update_attribute :examiner_id, assignee.id }
        assignee.update_attribute :n_assigned, (assignee.n_assigned + work.count)

        examiners.push assignee # push to last
      end # over students
    end

    # Update deadline field for each exam for which scans have been distributed 
    deadline = 3.business_days.from_now
    for e in exams
      e.update_attribute :deadline, deadline 
    end

    # Let the (offline) teacher know that scans have been received
    for t in by.uniq
      Mailbot.delay.scans_received(t)
    end
    
    # Let each grader know that he/she has got new scans to grade in their account
    for id in used.uniq
      Mailbot.delay.new_grading_work(id)
    end
  end

  def live?
    return true if self.live
    self.update_attribute(:live, true) if self.is_admin
    return false 
  end

end # of class
