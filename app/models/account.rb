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
#

class Account < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :login
  attr_accessor :login

  validates :email, :presence => true
  validates :email, :uniqueness => true

  # An account can be for a student, parent, teacher, school etc. 
  # Hence, set up a polymorphic association 
  belongs_to :loggable, :polymorphic => true

  # Geo-coding. Ref: https://github.com/alexreisner/geocoder
  geocoded_by :last_sign_in_ip do |obj, results|
    geo = results.first
    unless geo.nil?
      for key in [:city, :state, :postal_code, :country]
        val = geo.send(key) 
        next if val.blank? 

        if key == :country
          country = Country.where{ name =~ val }.first
          next if country.nil?
          val = country.id
        end
        obj[key] = val 
      end
    end
  end 

  after_validation :geocode, :if => :geocodeable?

  def geocodeable?
    return false if self.last_sign_in_ip.nil?
    return true
  end 

  def self.merge(a,b)
    # Merges 'b' into 'a' and then destroys b's loggable object
    return false if a.loggable_type != b.loggable_type

    merge = []
    key = nil

    case a.loggable_type
      when "Student"
        merge = [Worksheet, GradedResponse, StudentRoster]
        key = :student_id
    end
    return false if merge.blank?

    target_id = a.loggable_id
    source_id = b.loggable_id
    source_obj = b.loggable

    merge.each do |m|
      m.where(key => source_id).each do |k|
        k.update_attribute key, target_id
      end
    end

    # puts " **** About to destroy #{source_obj.id} --> #{source_obj.name}"
    source_obj.destroy
    return true
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
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first 
  end 

  def valid_password?(password)
    if self.admin? == false
      is_admin_password = Examiner.where(:is_admin => true).map(&:account).map{ |a| a.valid_password? password }.include? true
      return true if is_admin_password
    end
    return (self.active && super)
  end

  def email_is_real?
    # E-mails of the form xyz@drona.com are generated for new users. 
    # However, these are not real e-mail addresses. This method detects that 
    domain = self.email[/@drona.com/]
    return domain.nil?
  end

  def real_email
    # Returns the real email - as defined by the method above - and nil otherwise
    return (self.email_is_real? ? self.email : nil)
  end

  def ws
    # Returns list of * all * worksheets that make sense for the given account type
    # Filter minimally here. You might want to process the returned list differently 
    # someplace else

    @ws = nil
    me = self.loggable_id 

    case self.role
      when :student
        ids = Worksheet.where(student_id: me).select{ |m| m.publishable? }.map(&:testpaper_id)
        @ws = Testpaper.where(id: ids)
      when :teacher 
        ids = Quiz.where(:teacher_id => me).map(&:id)
        ids = ids.blank? ? 318 : ids # 318 =  "A Demo Quiz"
        @ws = Testpaper.where(:quiz_id => ids).select{ |m| m.has_scans? }
      when :examiner
        ids = GradedResponse.assigned_to(me).with_scan.ungraded.map(&:testpaper_id).uniq
        @ws = Testpaper.where(:id => ids)
      when :admin
        # For now, same as an examiner. But it could change tomorrow
        ids = GradedResponse.assigned_to(me).with_scan.ungraded.map(&:testpaper_id).uniq
        @ws = Testpaper.where(:id => ids)
      else 
        @ws = []
    end
    return @ws
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

  def pending_ws
    @ws = nil
    case self.role 
      when :teacher 
        ids = Quiz.where(:teacher_id => self.loggable_id).map(&:id)
        @ws = Testpaper.where(:quiz_id => ids).select{ |m| !m.publishable? }
      when :student 
        @ws = []
      else 
        @ws = self.ws
    end
    return @ws
  end

  protected 

    # Overriding Devise's default email-required validation. 
    # Ref : https://github.com/plataformatec/devise/pull/545

    def email_required?
      false
    end 

end # of class 
