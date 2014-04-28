
object false
  node(:proficiency) { 
    @proficiency
  } 

  node(:students){
    @students.map{ |s| { name: s.name, id: s.id } }
  }

  node(:benchmark) { @avg }
  node(:dbavg) { @db_avg }
  node(:last_pg) { @last }
