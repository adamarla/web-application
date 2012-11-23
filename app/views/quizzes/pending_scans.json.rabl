
node(:students) {
  @students.map{ |m| { 
      :marker => m.id, 
      :name => "#{m.abbreviated_name}"
      :class => :student, 
      :within => "#{@quiz_id}-#{@pending.select{ |k| k.student_id == m.id }.first.testpaper_id}"
   } }
} 

# @pending is an Ruby array - not ActiveRecord::Relation

node(:scans) {
  @scans.map { |m|
    @pending.select{ |k| k.scan == m}.take(1).map{ |n| { 
      :class => :scan, 
      :parent => n.student_id, 
      :name => m, 
      :marker => @scans.index(m) } 
    }
  } 
} 

node(:responses) {
  @pending.map{ |m| { 
    :label => m.name?, 
    :class => :gr, 
    :parent => @scans.index(m.scan), 
    :marker => m.id, 
    :mcq => m.subpart.mcq } 
  }
} 

