
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
    return false if self.errored_out?
    return self.job_id > 0
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

end
