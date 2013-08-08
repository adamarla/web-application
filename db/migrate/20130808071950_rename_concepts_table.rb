class RenameConceptsTable < ActiveRecord::Migration
  def change
    rename_table :concepts, :milestones
  end
end
