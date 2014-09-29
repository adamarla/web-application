
object false 
  node(:stabs){ 
    @uids.map{ |j| { id: j, 
                     name: Stab.uid_to_date(j).strftime("%b %d, %Y"),
                     badge: @stabs.where(uid: j).count } } 
  } 
