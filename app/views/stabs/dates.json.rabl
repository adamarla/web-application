
object false 
  node(:dates) { 
    @dates.map{ |j| { name: "#{Date.parse(j).strftime('%b %d, %Y')}", id: j } }
  } 
