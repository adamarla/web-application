class AddBilledToWorksheets < ActiveRecord::Migration
  def change
    add_column :worksheets, :billed, :boolean, default: false
  end
end
