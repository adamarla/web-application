
module ApplicationUtil

  def username_for( me, role )
    prefix = nil
    workable = false 

    [:first_name, :last_name, :tag].each do |method|
      workable |= me.respond_to?(method)
    end
    return nil if !workable

    last_bits = role == :school ? [] : (me.last_name.nil? ? [] : me.last_name.split)
    timestamp = Time.now.seconds_since_midnight.to_i.to_s(36)

    case role 
      when :admin 
        # achaturvedi.109t
        prefix = last_bits.empty? ? "#{me.first_name}" : "#{me.first_name[0]}#{last_bits.last}"
        suffix = timestamp
      when :examiner 
        # abhinav.chaturvedi.109t
        prefix = last_bits.empty? ? "#{me.first_name}" : "#{me.first_name}.#{last_bits.last}"
        suffix = timestamp
      when :teacher 
        # achaturvedi.109t.8n
        prefix = last_bits.empty? ? "#{me.first_name}" : "#{me.first_name[0]}#{last_bits.last}"
        suffix = "#{timestamp}.#{rand(999).to_s(36)}"
      when :student
        # abhinav.chaturvedi.109t.8n
        prefix = last_bits.empty? ? "#{me.first_name}" : "#{me.first_name}.#{last_bits.last}"
        suffix = "#{timestamp}.#{rand(999).to_s(36)}"
      when :school
        prefix = "principal.#{me.tag}"
    end 
    return "#{prefix}.#{suffix}".downcase
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
