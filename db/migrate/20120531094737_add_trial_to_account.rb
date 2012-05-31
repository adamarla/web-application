class AddTrialToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :trial, :boolean, :default => true
  end
end
