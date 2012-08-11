class AddAuditedToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :audited, :boolean, :default => false
  end
end
