class RemoveEmailFromTeacher < ActiveRecord::Migration
  def up
    remove_column :teachers, :email
  end

  def down
    add_column :teachers, :email, :string
  end
end
