class TransferKlassToStudent < ActiveRecord::Migration
  def up
    # At the time of writing, each student could belong to only one sektion
    # So the corresponding klass is what store as an attribute of the student 
    # Note, however, that StudentRoster model is in place at this time
    s_ids = StudentRoster.all.map(&:sektion_id).select{ |m| !m.nil? }.uniq
    s_ids.each do |sektion_id|
      klass = Sektion.where(:id => sektion_id).map(&:klass).first
      student_ids = StudentRoster.where(:sektion_id => sektion_id).map(&:student_id)
      Student.where(:id => student_ids).each do |m|
        m.update_attribute :klass, klass
      end
    end
  end

  def down
    # Unrolling this migration => removing the sektion column
  end
end
