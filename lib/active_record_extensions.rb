
module ActiveRecordExtensions
  
  # Delayed::Jobs are tried 3 times before finally failing.
  # After each try though, the job_id could be one of the following 
  # 
  # job_id = -1 => default initial state
  #        = -2 => write TeX error 
  #        = -3 => compile TeX error 
  #        = 0 => compilation completed
  #        > 0 => queued => compiling

  def compiling? 
    return false unless self.respond_to? :job_id
    return self.job_id > 0
  end 

  def compiled?
    return false unless self.respond_to? :job_id
    return self.job_id == 0
  end

  def errored_out?
    return false unless self.respond_to? :job_id
    return self.job_id < -1
  end

  def latex_safe_name 
    return nil unless self.respond_to? :name

    # The following 10 characters have special meaning in LaTeX and hence need to 
    # be escaped with a backslash before typesetting 
    safe = self.name 
    ['#', '$', '&', '^', '%', '\\', '_', '{',  '}', '~'].each do |m|
      safe = safe.gsub m, "\\\\#{m}"
    end 
    return safe
  end

  def activate
    # self = anything other than an Account object
    return false unless self.respond_to? :account
    return self.account.update_attribute :active, true
  end

  def deactivate
    # self = anything other than an Account object
    return false unless self.respond_to? :account
    self.account.update_attribute :active, false
    is_admin = (self.respond_to?(:is_admin) ? self.is_admin : nil) 
    return (is_admin.nil? ? true : (is_admin ? true : self.update_attribute(:live, false))) 
  end

  def apprentices
    return [] unless self.respond_to? :account
    is_teacher = self.account.loggable_type == 'Teacher'
    return Examiner.where(mentor_id: self.id, mentor_is_teacher: is_teacher)
  end 

  def mentor 
    return [] unless self.respond_to? :account
    return self.mentor_is_teacher ? Teacher.where(id: self.mentor_id) : Examiner.where(id: self.mentor_id)
  end 

  def country_code? 
    if self.respond_to? :account # => any loggable 
      self.account.nil? ? 'IN' : self.account.country_code?
    elsif self.respond_to? :country # => Account model  
      return Watan.where(id: self.country).map(&:alpha_2_code).first
    else
      return nil
    end 
  end 

  ####
  # Use only set_phone to store phone numbers. Do NOT use update_attribute
  ####
  def set_phone(phone)
    phone = phone.blank? ? nil : phone.to_s
    return false if phone.nil?

    normalized = PhonyRails.normalize_number(phone, country_code: self.country_code?)
    return false unless Phony.plausible?(normalized)

    if self.respond_to? :account
      a = self.account 
      # Only students can not have an associated account
      a.nil? ? self.update_attribute(:phone, normalized) : a.update_attribute(:phone, normalized)
    else
      return false
    end 
  end 

end # of extensions 

