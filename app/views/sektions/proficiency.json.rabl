
collection @students => :students
  attribute :name 
  node(:y){ |m| @students.index(m) + 1 }
  node(:relative){ |m| @relative[@students.index(m)] }
  node(:benchmark){ |m| @benchmark_teacher }
  node(:db){ |m| @benchmark_db }

