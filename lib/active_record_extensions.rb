
module ActiveRecordExtensions
  def compiling? 
    return false unless self.respond_to? :job_id
    # If compilation fails, then the calling object itself is destroyed. In which case
    # there is no way this method can be called. Otherwise,
    # job_id = -1 => default initial state
    #        > 0 => queued => compiling
    #        = 0 => compilation completed
    #        < -1 => some error
    return self.job_id > 0
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
