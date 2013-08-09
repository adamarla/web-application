class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :title, limit: 70
      t.text :description
      t.boolean :history, default: false

      t.timestamps
    end
  end
end
