# == Schema Information
#
# Table name: schools
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  street_address :string(255)
#  city           :string(40)
#  state          :string(40)
#  zip_code       :string(15)
#  phone          :string(20)
#  created_at     :datetime
#  updated_at     :datetime
#  tag            :string(40)
#  board_id       :integer
#  xls            :string(255)
#

class School < ActiveRecord::Base
  has_one :account, :as => :loggable
  has_many :students
  has_many :teachers
  has_many :sektions

  validates :name, :presence =>true
  validates :tag, :presence => true
  validates :zip_code, :presence => true
  validates :board_id, :presence => true

  mount_uploader :xls, ExcelUploader # Railscast #253

  scope :state_matches, lambda { |criterion| (criterion.nil? || criterion[:state].blank?) ? 
                              where('state IS NOT NULL') : where(:state => criterion[:state]) } 

  # Should we allow deletion of schools from the DB ? My view is, don't. 
  # Don't because whatever information you may have accumulated about the 
  # school and its students' performance is valuable. At most, disable the account.
  # Also, instead of trying to prevent deletion through controller and view,
  # - which can be hacked - de-fang the operation in the model itself. 

  before_destroy :destroyable? 

  def create_sektions(klasses, names) 
    # 'klasses' and 'names' are arrays 

    klasses.each { |klass|
      names.each { |name| 
        grp = self.sektions.new :klass => klass, :name => name 
        grp.save 
        # 'save' can fail because of uniqueness validation. That's ok
      }
    }
    return true 
  end # of method  

  def activate(state)
    # activates/deactivates a school's account and also of anyone - students
    # or teachers - associated with it. Pass 'true' to activate, 'false' to deactivate

    a = self.account
    teachers = self.teacher_ids 
    students = self.student_ids

    Account.where(:loggable_type => "Teacher", :loggable_id => teachers).each do |m|
      m.update_attribute :active, state
    end

    Account.where(:loggable_type => "Student", :loggable_id => students).each do |m|
      m.update_attribute :active, state
    end

    a.update_attribute :active, state
  end

  def enroll(name, email = nil, klass = nil, sektion = nil)
    return false if name.blank?
    student = self.students.build :name => name
    username = create_username_for student, :student
    return false if username.blank?

    email = "#{username}@drona.com" if email.blank?
    unless sektion.nil?
      student.klass = sektion.klass
      student.sektions << sektion # Add student to just created sektion
    else
      student.klass = klass
    end
    password = self.zip_code
    account = student.build_account :username => username, :email => email, 
                                    :password => password, :password_confirmation => password
    return student.save
  end

  private 
    def destroyable? 
      return false
    end 
end
