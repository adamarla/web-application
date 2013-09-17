class CreateConcepts < ActiveRecord::Migration
  def change
    create_table :concepts do |t|
      t.string :name, limit: 70
      t.integer :index, default: -1
      t.integer :course_id

      t.timestamps
    end
  end
end
