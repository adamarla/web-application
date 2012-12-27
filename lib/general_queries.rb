
module GeneralQueries
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

  def mangle_feedback(hash) 
    # 'hash' is params[:checked] submitted via a form by the grader
    # Returns: An integer that should be stored as feedback for the graded response
  end

  def unmangle_feedback(n)
    # 'n' is the 32-bit number stored as feedback for a graded response in the DB
    # Returns: (overall, cogency, completeness, [ other issues ])
  end

  def quantify_feedback(n)
    # Returns: Percentage of marks to give based on stored feedback 
  end

  def rubric_first_of_x_at(type)
    # Returns the 0-indexed relative position of the * first * item listed under heading 'type'
    # Assumes relative position of 'honest', 'cogent', 'complete' and 'other' is maintained in YAML
    case type 
      when 'honest' then prev = []
      when 'cogent' then prev = ['honest']
      when 'complete' then prev = ['honest', 'cogent']
      when 'other' then prev = ['honest', 'cogent', 'complete']
    end
    ret = 0 
    prev.each { |m| ret += Rubric[m].length }
    return ret > 0 ? ret - 1 : 0
  end

end
