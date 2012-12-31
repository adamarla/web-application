
collection @students => :students 
  attributes :name, :id
  node(:y){ |m| @students.count - @students.index(m) }
  node(:mean){ |m| @mean }
  node(:marks) { |m| m.marks_scored_in @testpaper.id }
  node(:graded) { |m| @answer_sheet.of_student(m.id).first.graded? } 
  # node(:graded_thus_far) { |m| @answer_sheet.of_student(m.id).first.graded_thus_far? }
  node(:max) { |m| @max }
  node(:tag) { |m| @answer_sheet.of_student(m.id).first.graded_thus_far_as_str } 
