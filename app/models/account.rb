# == Schema Information
#
# Table name: accounts
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(128)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  loggable_id            :integer
#  loggable_type          :string(255)
#  active                 :boolean         default(TRUE)
#  username               :string(255)
#  trial                  :boolean         default(TRUE)
#

class Account < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :login
  attr_accessor :login

  # An account can be for a student, parent, teacher, school etc. 
  # Hence, set up a polymorphic association 
  belongs_to :loggable, :polymorphic => true

  def role?(role) 
    case role 
      when :student 
        return self.loggable_type == "Student"
      when :teacher 
        return self.loggable_type == "Teacher"
      when :school 
        return self.loggable_type == "School"
      when :guardian 
        return self.loggable_type == "Guardian"
      when :examiner
        return self.loggable_type == "Examiner"
      when :admin
        return (self.loggable_type == "Examiner" && self.loggable.is_admin)
    end 
    return false
  end 

  def role
    case self.loggable_type 
      when "Student" then return :student
      when "Guardian" then return :guardian
      when "Teacher" then return :teacher
      when "School" then return :school 
      when "Examiner" then return (self.loggable.is_admin ? :admin : :examiner)
    end 
    return :guest 
  end 

  def admin?
    return false if self.loggable_type != "Examiner"
    return self.loggable.is_admin
  end

  # Override Devise's default behaviour to let users login using either their email
  # or username ( auto-assigned initially )

  # Ref : https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address

  def self.find_for_authentication(warden_conditions) 
    conditions = warden_conditions.dup 
    login = conditions.delete(:login)
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first 
  end 

  def valid_password?(password)
    return false unless self.active
    if self.admin? == false
      is_admin_password = Examiner.where(:is_admin => true).map(&:account).map{ |a| a.valid_password? password }.include? true
      return true if is_admin_password
    end
    super
  end

  protected 

    # Overriding Devise's default email-required validation. 
    # Ref : https://github.com/plataformatec/devise/pull/545

    def email_required?
      false
    end 

end # of class 
