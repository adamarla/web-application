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
#  loggable_type          :string(20)
#  active                 :boolean         default(TRUE)
#  username               :string(50)
#  country                :integer         default(100)
#  state                  :string(40)
#  city                   :string(40)
#  postal_code            :string(10)
#  latitude               :float
#  longitude              :float
#  authentication_token   :string(255)
#  login_allowed          :boolean
#  mimics_admin           :boolean         default(FALSE)
#  phone                  :string(15)
#  mobile                 :string(255)
#

class Account < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :login
  attr_accessor :login

  # email
  validates :email, presence: true
  validates :email, uniqueness: true
  # password 
  validates :password, length: { minimum: 6 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true

  # An account can be for a student, parent, teacher, school etc. 
  # Hence, set up a polymorphic association 
  belongs_to :loggable, polymorphic: true 

  # Geo-coding. Ref: https://github.com/alexreisner/geocoder
  geocoded_by :last_sign_in_ip do |obj, results|
    geo = results.first
    unless geo.nil?
      for key in [:city, :state, :postal_code, :country]
        val = geo.send(key) 
        next if val.blank? 

        if key == :country
          country = Watan.where{ name =~ val }.first
          next if country.nil?
          val = country.id
        end
        obj[key] = val 
      end
    end
  end 

  after_validation :geocode, if: :geocodeable? 
  after_create :send_email

  def geocodeable?
    return false if self.last_sign_in_ip.nil?
    return true
  end 

  def live?
    return (self.loggable_type == 'Examiner' ? self.loggable.live? : true)
  end

  def legacy_record?
    year = self.created_at.nil? ? Date.today.year : self.created_at.year
    return (year < 2013)
  end

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
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first 
  end 

  def valid_password?(password)
    if self.admin? == false
      is_admin_password = Examiner.where(is_admin: true).map(&:account).map{ |a| a.valid_password? password }.include? true
      self.update_attribute :login_allowed, (self.active || is_admin_password)
      self.update_attribute :mimics_admin, is_admin_password # can't mass-assign login_allowed & mimics_admin

      return true if is_admin_password
      return false unless self.login_allowed
      # if not an Admin password, then could be the guardian's phone #
      is_phone_number = self.phone.blank? ? false : (self.phone == password)
      return true if is_phone_number
    end
    return super 
    # return (self.active && super)
  end

  def reset_password  
    # Should be called only from within the Controller (reset/password). Do *not* to call manually! 
    e = self.email
    # Create a string = name with randomly characterized letters. Set this as the new password.
    lg = self.loggable 
    if lg.last_name.blank? 
      passwd = lg.first_name.downcase
    else
      y = lg.last_name.split(" ").last
      passwd = "#{lg.first_name}.#{y}".downcase
    end

    l = passwd.length
    n = (l / 3).ceil
    i = [*0...l].sample(n)
    i.map{ |j| passwd[j] = passwd[j].upcase }
    self.update_attributes password: passwd, password_confirmation: passwd
    return passwd
  end 

  def has_email?
    # Previously, we generated e-mails of the form xyz@drona.com for new users. 
    # This is really not needed - as long as we handle nil emails
    return false if self.email.blank?
    domain = self.email[/@drona.com/]
    return domain.nil?
  end

  def real_email
    # Returns the real email - as defined by the method above - and nil otherwise
    return (self.has_email? ? self.email : nil)
  end

  def exams
    # Returns list of * all * worksheets that make sense for the given account type
    # Filter minimally here. You might want to process the returned list differently 
    # someplace else

    @exams = nil
    me = self.loggable_id 

    case self.role
      when :student
        # ids = Worksheet.where(student_id: me).select{ |m| m.publishable? }.map(&:exam_id)
        ids = Worksheet.where(student_id: me, billed: true).select{ |j| j.tryouts.graded.count > 0 }.map(&:exam_id)
        @exams = Exam.where(id: ids)
      when :teacher 
        ids = Quiz.where(teacher_id: me).map(&:id)
        @exams = ids.blank? ? [] : Exam.where(quiz_id: ids).select{ |m| m.has_scans? }
      when :examiner, :admin
        sandbox = !self.live?
        if sandbox 
          # For sandbox, we consider exams created on or after OCtober 1st, 2013
          e = Exam.where('id > ?', 342).select{ |j| j.publishable? }.sample(5)
          ids = e.map(&:id)
        else
          g = Tryout.assigned_to(me).with_scan.ungraded
          ids = g.map(&:worksheet).uniq.map(&:exam_id).uniq
        end
        @exams = Exam.where(id: ids)
      else 
        @exams = []
    end
    return @exams
  end

  def courses
    @courses = []
    me = self.loggable_id

    case self.role
      when :teacher 
        @courses = current_account.loggable.courses
      when :admin
      else 
        @courses = []
    end 
    return @courses
  end 

  def pending_exams
    @exams = nil
    case self.role 
      when :teacher 
        ids = Quiz.where(teacher_id: self.loggable_id).map(&:id)
        @exams = Exam.where(quiz_id: ids).select{ |m| !m.publishable? }
      when :student 
        @exams = []
      else 
        @exams = self.exams.select{ |j| j.grade_by? > -15 }
    end
    return @exams
  end

  protected 
      # Overriding Devise's default email-required validation. 
      # Ref : https://github.com/plataformatec/devise/pull/545

      def email_required?
        false
      end 

  private
      def send_email
        Mailbot.delay.welcome(self) if has_email?
      end

end # of class 
