
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

  def circular_slice(array, start, n)
    # returns an array of indices in 'array' starting at 'start' and going 
    # upto the next 'n' elements. If 'n' takes one beyond the end of the
    # array, then wraps around to 0 and starts picking indices from there
    #   Example: If array = [1,2,3], then circular_slice(array, 1, 3) -> [2,3,1]
    #            and circular_slice(array,1,7) -> [2,3,1,2,3,1,2]

    y = array
    last = start + n 
    n_concat = last / array.length
    [*0...n_concat].each do |j|
      y += array 
    end
    return y[start, n]
  end


end # of module 
