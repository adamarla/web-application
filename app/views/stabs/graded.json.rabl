
object false 
  node(:stabs){ 
    @uids.map{ |j| { id: j, 
                     name: Stab.uid_to_date(j),
                     badge: @stabs.where(uid: j).count } } 
  } 
