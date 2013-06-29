class AddAuditDataToQuestion < ActiveRecord::Migration
  def up
    remove_column :questions, :audited
    rename_column :questions, :audited_by, :auditor
    add_column :questions, :audited_on, :datetime
    add_column :questions, :available, :boolean, :default => true
  end 

  def down
    remove_column :questions, :available
    remove_column :questions, :audited_on
    rename_column :questions, :auditor, :audited_by
    add_column :questions, :audited, :boolean, :default => false
  end 
end
