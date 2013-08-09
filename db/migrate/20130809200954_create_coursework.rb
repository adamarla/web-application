class CreateCoursework < ActiveRecord::Migration
  def change
    create_table :coursework do |t|
      t.integer :milestone_id
      t.integer :quiz_id

      t.timestamps
    end
  end
end
