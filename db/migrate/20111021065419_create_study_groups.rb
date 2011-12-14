class CreateStudyGroups < ActiveRecord::Migration
  def change
    create_table :study_groups do |t|
      t.integer :school_id
      t.integer :grade
      t.string :section

      t.timestamps
    end
  end
end
