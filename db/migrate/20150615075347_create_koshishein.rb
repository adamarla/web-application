class CreateKoshishein < ActiveRecord::Migration
  def change
    create_table :koshishein do |t|
      t.integer :pupil_id 
      t.integer :question_id 
      t.boolean :seen_options, default: false
      t.integer :num_wrong, default: 0
      t.boolean :got_right
      t.integer :max_opened, default: 0
      t.integer :max_time
      t.timestamps
    end
    add_index :koshishein, :pupil_id
    add_index :koshishein, :question_id
  end
end
