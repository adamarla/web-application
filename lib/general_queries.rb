
module GeneralQueries
  BIG_7 = (36 ** 7) - 1
  BIG_3 = (36 ** 3) - 1

  def pagination_layout_details(n_entries)
=begin
    Kaminari offers helpful helper methods to generate the correct # of 
    pagination links - given the number of records per page

    But that works only if you're rendering the links in HAML. If, however, you
    rely on JSON, then your only option is to render a * fixed * number of 
    pagination links and fit in all your results in at most those number 
    of fixed links 

    This method returns therefore the number of pages that would be 
    required and the # of records per page - given the total # of entries
    Return values (in order): # of entries per page, # reqd pages (max 8)
=end
    default_per_pg = 25
    max_pages = 6 

    per_pg = (n_entries / default_per_pg.to_f).ceil > max_pages ? (n_entries / max_pages.to_f).ceil : default_per_pg 
    n_pgs = (n_entries / per_pg.to_f).ceil
    return per_pg, n_pgs
  end
  
  def mangle_unmangle(original)
    string = original.clone
    len = string.length
    last = len - 1
    middle = len / 2

    [*0..middle].each do |j|
      k = string[j]
      string[j] = string[last - j]
      string[last - j] = k
    end
    return string
  end

  def encrypt(number, width)
    # returned string would be of length = 'width'
    return if (width != 7 && width != 3)
     
    # Step 1: Subtract given from a constant to get a new number 
    number = (width == 7) ? (BIG_7 - number) : (BIG_3 - number)
    m = number.to_s(36).upcase
     
    # Step 2: Pad - as needed 
    padding = width - m.length
    m = padding > 0 ? ('0' * padding + m) : m
    
    # Step 3: Mangle - as needed
    m = mangle_unmangle m
    return m
  end

  def decrypt(string)
    m = mangle_unmangle string
    len = m.length
    number = m.to_i(36)
    number = len == 7 ? (BIG_7 - number) : (BIG_3 - number)
    return number
  end

end
