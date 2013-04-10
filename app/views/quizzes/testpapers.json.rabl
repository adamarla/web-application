
object false 
  node(:testpapers) {
    @testpapers.map { |m|
      { :name => "#{m.name}", :tag => "#{m.created_at.to_date.strftime('%b %Y')}", :id => m.id }
    }
  } 

  node(:last_pg) { @last_pg }
