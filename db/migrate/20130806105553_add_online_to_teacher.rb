class AddOnlineToTeacher < ActiveRecord::Migration
  def change
    add_column :teachers, :online, :boolean, default: false
  end
end
