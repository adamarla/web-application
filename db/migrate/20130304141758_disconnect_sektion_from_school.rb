class DisconnectSektionFromSchool < ActiveRecord::Migration
  def up
    # Uniquely assign sektions that have teacher_id => nil to a teacher
    # The code below works on the assumption that thus far teachers 
    # have made quizzes only for their school mandated sektions

    Quiz.all.each do |q|
      tp = q.testpaper_ids
      sids = AnswerSheet.where(:testpaper_id => tp).map(&:student_id).uniq
      skids = StudentRoster.where(:student_id => sids).map(&:sektion_id)
      Sektion.where(:id => skids, :teacher_id => nil).each do |sk|
        sk.update_attribute :teacher_id, q.teacher_id
      end 
    end 
    # Then drop school_id, exclusive & klass from Sektion
    remove_column :sektions, :school_id
    remove_column :sektions, :exclusive
    remove_column :sektions, :klass

    # Add a uid:string column. The UID will be what the teacher shares with students 
    # When a student enters the UID, he/she becomes part of that sektion
    add_column :sektions, :uid, :string, :limit => 10
  end

  def down
    add_column :sektions, :school_id, :integer
    add_column :sektions, :exclusive, :boolean, :default => false
    add_column :sektions, :klass, :integer
    remove_column :sektions, :uid

    Sektion.all.each do |sk|
      next if sk.teacher_id.nil?
      sk.update_attribute :school_id, sk.teacher.school_id unless sk.teacher.school_id.nil?
    end 
  end
end
