class MakeSektionTeacherSpecific < ActiveRecord::Migration
  def change 
    add_column :sektions, :teacher_id, :integer
    add_column :sektions, :exclusive, :boolean, :default => false
  end
end
