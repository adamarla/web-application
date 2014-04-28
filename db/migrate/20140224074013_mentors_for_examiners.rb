class MentorsForExaminers < ActiveRecord::Migration
  def change
    add_column :examiners, :mentor_id, :integer 
    add_column :examiners, :mentor_is_teacher, :boolean, default: false
    add_index :examiners, :mentor_id
  end
end
