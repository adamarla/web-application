class CreateExpertise < ActiveRecord::Migration
  def change
    create_table :expertise do |t|
      t.integer :pupil_id 
      t.integer :skill_id 
      t.integer :num_tested, default: 0 
      t.integer :num_correct, default: 0 
    end

    add_index :expertise, :pupil_id 
    add_index :expertise, :skill_id  
  end

end
