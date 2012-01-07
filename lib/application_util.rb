
module ApplicationUtil

  def username_prefix_for( me, role )
    prefix = nil
    workable = false 

    [:first_name, :last_name, :tag].each do |method|
      workable |= me.respond_to?(method)
    end
    return nil if !workable

    case role 
      when :teacher, :admin 
        prefix = "#{me.first_name[0]}#{me.last_name}".downcase
      when :student, :examiner
        prefix = "#{me.first_name}#{me.last_name[0]}".downcase
      when :school
        prefix = "principal.#{me.tag}".downcase
    end 
    return prefix
  end

  def create_username_for( me,role )
    username = nil
    prefix = username_prefix_for me, role
    return nil if prefix.nil?

    case role 
      when :student, :teacher
        blacklist = ['TITS', 'ARSE', 'ASS', 'DICK', 'SEX', 'BOOB', 'CHUT', 'LODA', 'TIT', 'TITY']
        timestamp = Time.now.seconds_since_midnight.to_i.to_s(36).upcase
        while blacklist.include? timestamp
          sleep 1 # wait for 1 second
          timestamp = Time.now.seconds_since_midnight.to_i.to_s(36).upcase
        end
        username = "#{prefix}.#{timestamp}"
      else 
        username = prefix
    end 
    return username
  end

end
