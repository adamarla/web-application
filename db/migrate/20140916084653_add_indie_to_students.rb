class AddIndieToStudents < ActiveRecord::Migration
  def change
    add_column :students, :indie, :boolean
  end
end
