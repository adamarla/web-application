# == Schema Information
#
# Table name: schools
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  phone      :string(20)
#  created_at :datetime
#  updated_at :datetime
#  xls        :string(255)
#  uid        :string(10)
#

class School < ActiveRecord::Base
  has_one :account, as: :loggable 
  has_many :teachers

  validates :name, presence: true 
  validates_associated :account 

  after_create :assign_uid

  # Should we allow deletion of schools from the DB ? My view is, don't. 
  # Don't because whatever information you may have accumulated about the 
  # school and its students' performance is valuable. At most, disable the account.
  # Also, instead of trying to prevent deletion through controller and view,
  # - which can be hacked - de-fang the operation in the model itself. 

  before_destroy :destroyable? 

  attr_accessor :email

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
    username = username_for student, :student
    return false if username.blank?

    email = "#{username}@drona.com" if email.blank?
    unless sektion.nil?
      student.klass = sektion.klass
      student.sektions << sektion # Add student to just created sektion
    else
      student.klass = klass
    end
    password = self.account.postal_code
    account = student.build_account username: username, email: email, password: password, password_confirmation: password
    return student.save
  end

  def assign_uid
    uid = "#{self.id.to_s(36)}#{rand(99999).to_s(20)}"
    uid = uid.upcase
    self.update_attribute :uid, uid
  end

  private 
    def destroyable? 
      return false
    end 
end
