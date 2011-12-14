class CreateGradeDescriptions < ActiveRecord::Migration
  def change
    create_table :grade_descriptions do |t|
      t.string :annotation
      t.string :description
      t.integer :default_allotment

      t.timestamps
    end
  end
end
