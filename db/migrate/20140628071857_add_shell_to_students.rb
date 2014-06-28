class AddShellToStudents < ActiveRecord::Migration
  def change
    add_column :students, :shell, :boolean, default: false
  end
end
