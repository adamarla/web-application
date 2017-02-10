class CreateRiddles < ActiveRecord::Migration
  def change
    english = Language.named 'English'
    medium = Difficulty.named 'Medium' 

    create_table :riddles do |t|
      t.string :type, limit: 50
      t.integer :original_id 
      t.integer :chapter_id 
      t.integer :parent_riddle_id 
      t.integer :language_id, default: english 
      t.integer :difficulty, default: medium 
      t.integer :num_attempted, default: 0 
      t.integer :num_completed, default: 0 
      t.integer :num_correct, default: 0 
      t.integer :examiner_id 
    end

    # Hugely important! 
    # As all Question and Snippet records will now be housed in 
    # one Riddle table, we must guard against a record's ID in
    # the old table clashing with primary key ID in the new table. 
    # Hence, we start ID in Riddle at 2000 

    execute("ALTER SEQUENCE riddles_id_seq START with 2000 RESTART;")

    add_index :riddles, :chapter_id 
    add_index :riddles, :language_id 
    
  end # of change 
end
