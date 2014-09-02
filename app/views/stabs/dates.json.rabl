
object false 
  node(:dates) { 
    @dates.map{ |j| { name: "#{Stab.uid_to_date(j).strftime('%b %d, %Y')}", id: j } }
  } 
