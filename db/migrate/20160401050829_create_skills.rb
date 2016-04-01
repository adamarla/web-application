class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.integer :chapter_id 
      # t.timestamps
    end
  end
end
