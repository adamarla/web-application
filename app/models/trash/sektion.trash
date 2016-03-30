# == Schema Information
#
# Table name: sektions
#
#  id                   :integer         not null, primary key
#  name                 :string(40)
#  created_at           :datetime
#  updated_at           :datetime
#  teacher_id           :integer
#  uid                  :string(10)
#  start_date           :date
#  end_date             :date
#  auto_renew           :boolean         default(TRUE)
#  active               :boolean
#  auto_renew_immediate :boolean         default(FALSE)
#

class Sektion < ActiveRecord::Base
  belongs_to :teacher
  validates :name, presence: true

  has_many :student_rosters, dependent: :destroy
  has_many :students, through: :student_rosters

  after_create :seal

  def self.in_school(s)
    where(:teacher_id => Teacher.where(:school_id => s).map(&:id))
  end

  def self.common_to(student_ids)
    ids = Student.where(id: student_ids).map(&:sektion_ids).inject(:&)
    return ids.blank? ? nil : Sektion.where(id: ids).order(:created_at)
  end

  def self.destroyable
    # Sektions that can be - and should be - destroyed
    select{ |m| !m.active? && m.student_ids.count == 0 }
  end

  def self.monthly_audit
    # Called via a cron curl request on the 1st of every month 
    # Activates / deactivates sektions as needed 
    # The cron-job should be set for no earlier than 5:30AM IST 
    today = Date.today
    freshman = Sektion.where(start_date: today)
    graduates = Sektion.where(active: true, end_date: today.yesterday)

    for f in freshman
      f.update_attribute(:active, true)
    end 

    for g in graduates
      g.graduate if g.auto_renew
    end
  end

  def self.upcoming?(in_n_days = 3)
    today = Date.today
    where(active: false).where('start_date > ? AND start_date < ?', today, (today + in_n_days.days))
  end

  def active?
    # (adjective)
    return self.active unless self.active.nil?

    if (self.start_date.nil? || self.end_date.nil?)
      active = false
    else
      today = Date.today
      active = (self.start_date <= today && self.end_date > today)
    end
    self.update_attribute :active, active 
    return active
  end

  def future?
    return false if self.start_date.nil?
    return (self.start_date > Date.today)
  end

  def graduated? 
    return true if self.end_date.nil?
    return (self.end_date < Date.today)
  end

  def lifetime_in_days
    return 0 if (self.start_date.nil? || self.end_date.nil?)
    return (self.end_date- self.start_date).to_i
  end

  def active_period?
    return "" if ( self.start_date.nil? || self.end_date.nil? )
    return "#{self.start_date.strftime('%b\'%y')}-#{self.end_date.strftime('%b\'%y')}"
  end

  def taught_by? (teacher) 
    return self.teacher_id == teacher.id
  end 

  def pdf
    # UNIX has problem w/ some non-word characters in filenames
    # TeX has a problem w/ most of the rest ( unless escaped ). No one has a problem
    # with the hyphen. So, we do everything to only have it in the PDF file name
    pdf_file = "#{self.name.split(/[\s\W]+/).join('-')}"
    return pdf_file 
  end

=begin
  This next method is for one-time-call only and then too only from within a migration file
  It has been written as part of the transition scheme for supporting many-to-many mapping 
  between students and sektions. Once the transition is done, this method has no utility!

  Its like the 2 methods written in question.rb. Those were written for subpart support
=end
  def self.build_student_roster
    # Available tables: student_roster and student w/ sektion_id
    Student.all.each do |s|
      roster = StudentRoster.new :student_id => s.id, :sektion_id => s.sektion_id
      roster.save
    end # of students loop  
  end # up  

  def self.unbuild_student_roster
    # Available tables: student_roster and student w/ sektion_id
    # Complication: in the student_roster, one student may be mapped to > 1 sektions
    # As this is a roll-back, one would have to assign the student to one of the 
    # many sektions he/she may previously assigned to. Not a perfect solution, but the best we can do

    Student.all.each do |s|
      sektion = StudentRoster.where(:student_id => s.id).map(&:sektion_id).first
      s.update_attribute :sektion_id, sektion
    end
  end #down
    
  def rebuild_student_roster_pdf
    students = self.students.map{ |m| { :id => m.username?, :name => m.name } }
    students.push({ :id => "", :name => ""}) if students.count.odd?

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['generate_student_roster']}" 

    response = SavonClient.request :wsdl, :generateStudentRoster do  
      soap.body = {
        :school => { :id => self.school_id, :name => self.school.name },
        :group => { :id => self.id, :name => self.pdf },
        :members => students 
      }
     end # of response 
     return response.to_hash[:generate_student_roster]
  end

  def enroll(ids = [])
    self.student_ids = self.student_ids + ids 
  end 

  def unenroll(ids = [])
    self.student_ids = self.student_ids - ids 
  end 

  public 
      def graduate
        # (verb): Create a new sektion with the same lifetime as self
        return false unless self.active

        t = self.teacher 
        return false unless (t.account.active && self.auto_renew)

        lifetime = self.lifetime_in_days 
        start = self.auto_renew_immediate ? Date.today.beginning_of_month : (self.start_date + 1.year)
        expiry = (start + lifetime.days).end_of_month 

        neu = t.sektions.create name: self.name, start_date: start, end_date: expiry,
                                auto_renew: true, auto_renew_immediate: self.auto_renew_immediate
        self.update_attribute :active, false
      end

  private 
      def seal 
        uid = "#{self.teacher_id.to_s(36)}#{rand(99999).to_s(20)}".upcase
        self.update_attributes uid: uid, name: self.name.squish.titleize
        # Let the teacher know  
        Mailbot.delay.new_sektion(self) unless self.teacher.indie
      end 

end
