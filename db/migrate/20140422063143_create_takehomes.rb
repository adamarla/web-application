class CreateTakehomes < ActiveRecord::Migration
  def change
    create_table :takehomes do |t|
      t.integer :course_id 
      t.integer :quiz_id
      t.integer :index, default: 0
      t.timestamps
    end
  end
end
