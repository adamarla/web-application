class AddAuditedByToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :audited_by, :integer
  end
end
