
collection @subjects => :subjects
  attribute :id => :parent
  node(:id) { |m| Specialization.where(:teacher_id => @teacher.id, :subject_id => m.id).map(&:klass) }

