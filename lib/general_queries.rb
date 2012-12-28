
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

end
