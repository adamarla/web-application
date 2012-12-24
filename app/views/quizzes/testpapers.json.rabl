
object false 
  node(:testpapers) {
    @testpapers.map { |m|
      { :testpaper => { :name => "#{m.name}", :tag => "#{m.created_at.to_date.strftime('%b %d, %Y')}", :id => m.id } }
    }
  } 

  node(:last_pg) { @last_pg }
