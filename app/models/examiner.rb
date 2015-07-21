# == Schema Information
#
# Table name: examiners
#
#  id                :integer         not null, primary key
#  created_at        :datetime
#  updated_at        :datetime
#  is_admin          :boolean         default(FALSE)
#  first_name        :string(30)
#  last_name         :string(30)
#  last_workset_on   :datetime
#  n_assigned        :integer         default(0)
#  n_graded          :integer         default(0)
#  live              :boolean         default(FALSE)
#  mentor_id         :integer
#  mentor_is_teacher :boolean         default(FALSE)
#  internal          :boolean         default(FALSE)
#

include GeneralQueries

class Examiner < ActiveRecord::Base
  has_one :account, as: :loggable
  has_many :tryouts
  has_many :suggestions
  has_many :doodles, dependent: :destroy # will destroy associated remarks 
  has_many :remarks # choosing not to destroy 'live' remarks  
  has_many :stabs

  validates_associated :account

  # [:all] ~> [:admin]
  # [:disputed] ~> [:student]
  #attr_accessible :disputed

  def self.available
    select{ |m| !m.account.nil? && m.live? }
  end

  def self.internal 
    where(internal: true)
  end 

  def self.teaching_assistant_to(id)
    where(mentor_is_teacher: true, mentor_id: id)
  end

  def self.experienced
    where('(internal = ? AND n_graded > ?) OR (internal = ? AND n_graded > ?)', true, 1000, false, 2000)
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

  def block_db_slots( n = 10 )
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
      q = Question.new uid:  s, examiner_id: self.id
      slots.delete s unless q.save # return only those slots that got created
    end
    return slots
  end

  def pending_workload
    return Tryout.where(examiner_id: self.id).where('grade_id IS NULL').count
  end

=begin
    Distribution methods - one of Stabs and one for Tryouts
    Hopefully, the one for Tryouts (institutional environment) will die out soon.
=end

  def self.distribute_stabs 
    stabs = Stab.unassigned.with_scan.order(:student_id) # ug = ungraded
    stabs.each do |s|
      s.update_attribute :examiner_id, 17 # 17 = James Haddock. 
    end
=begin
    examiners = Examiner.where(mentor_is_teacher: false).available # registered, non-TA graders 

    are_puzzles = [true, false]

    are_puzzles.each do |is_puzzle|
      graders = examiners.order(:n_assigned)

      if is_puzzle 
        graders = graders.internal
        work = stabs.at_puzzles 
      else
        work = stabs.at_questions 
      end 

      work.map(&:student_id).uniq.each_slice(5) do |m| 
        exm = graders.shift # pop from front
        work.by(m).map{ |n| n.assign_to(exm) }
        graders.push exm
      end # each_slice
    end # of each  
=end
  end # of method

  def self.distribute_scans
    ug = Tryout.unassigned.with_scan # ug = ungraded
    exams = ug.map(&:worksheet).uniq.map(&:exam).uniq 
    offline = exams.map(&:quiz).uniq.map(&:teacher).select{ |t| !t.indie }

    for e in exams 
      scheme = e.distribution_scheme? 
      t = e.quiz.teacher
      ta_ids = t.apprentices.available.map(&:id) # available TAs - if any
      pending = ug.in_exam(e.id)

      pending.map(&:q_selection_id).uniq.each do |q|
        p = pending.where(q_selection_id: q) # same question, same quiz, all students

        if ta_ids.blank? # no TAs 
          examiners = Examiner.where(mentor_is_teacher: false).order(:n_assigned).available # registered, non-TA graders 
        else # has TAs 
          eid = scheme.blank? ? nil : scheme[q] # examiners for given q_selection
          j = eid.blank? ? ta_ids : (ta_ids & eid)
          j = ta_ids if j.blank?
          examiners = Examiner.where(id: j).order(:n_assigned) # ta_ids ensures availability 
        end 

        sids = p.map(&:student_id).uniq
        n_examiners = examiners.count 
        per = (sids.count / n_examiners)
        per = per > 20 ? per : 20

        sids.each_slice(per).each do |k|
          # ignore student if scans for all subparts not in
          is_complete = Tryout.where(student_id: k, q_selection_id: q).without_scan.count == 0
          next unless is_complete

          exm = examiners.shift # pop from front 
          work_chunk = p.where(student_id: k) # same question, same quiz, one student
          work_chunk.map{ |m| m.update_attribute :examiner_id, exm.id }
          exm.update_attribute :n_assigned, (exm.n_assigned + work_chunk.size)
          examiners.push exm # push to last
        end # over students
      end # over q-selections 

      # Update grade_by field
      deadline = ta_ids.blank? ? 3.business_days.from_now : 5.business_days.from_now
      e.update_attribute :grade_by, deadline
    end 
  end

  def live?
    return true if self.live
    is_live = self.is_admin ? true : false
    self.update_attribute(:live, true) if is_live
    return is_live 
  end

  def mail_daily_digest(tbd_grading, tbd_disputes)
    x = tbd_grading ? 'Yes' : 'No'
    y = tbd_disputes ? 'Yes' : 'No' 
    name = self.first_name
    Mailbot.delay.daily_digest name, self.account.email, x, y
  end

end # of class
