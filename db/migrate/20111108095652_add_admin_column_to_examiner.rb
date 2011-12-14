class AddAdminColumnToExaminer < ActiveRecord::Migration
  def change
    add_column :examiners, :is_admin, :boolean, :default => false
  end
end
