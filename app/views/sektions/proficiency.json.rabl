
collection @students => :students
  attribute :name 
  node(:y){ |m| @students.count - @students.index(m) }
  node(:relative){ |m| @relative[@students.index(m)] }
  node(:benchmark){ |m| @benchmark_teacher }
  node(:db){ |m| @benchmark_db }
