class TransferKlassToSpecialization < ActiveRecord::Migration
  def up
    # Specialization is now defined as the combination of subject and 
    # grade-level a teacher teaches. Previously, it was just the subject

    # 1. Create new records - with klass information - from existing records
    teachers = Teacher.all 
    teachers.each do |t| 
      subjects = Specialization.where(:teacher_id => t.id).map(&:subject_id).uniq 
      klasses = FacultyRoster.where(:teacher_id => t.id).map(&:sektion).map(&:klass).uniq

      klasses.each do |kl| 
        subjects.each do |sbj|
          ns = Specialization.new :teacher_id => t.id, :klass => kl, :subject_id => sbj
          ns.save
        end #sbj 
      end # kl 
    end # t

    # 2. Delete existing records - that is - those prior to the just added ones 
    teachers.each do |t| 
      Specialization.where(:teacher_id => t.id, :klass => nil).each do |spl|
        spl.destroy
      end
    end 
  end # up

  def down
    # Reduce granularity to just store the subject a teacher teaches 
    # At this time, only records with teacher, subject_id and klass are in the table 
    teachers = Teacher.all 
    teachers.each do |t| 
      subjects = Specialization.where(:teacher_id => t.id).map(&:subject_id).uniq
      subjects.each do |sbj|
        spl = Specialization.new :teacher_id => t.id, :subject_id => sbj 
        spl.save 
      end # sbj 
    end # t

    teachers.each do |t| 
      prior = Specialization.where(:teacher_id => t.id).where('klass IS NOT NULL')
      prior.each do |spl|
        spl.destroy
      end # spl 
    end # t
  end # down 
end
