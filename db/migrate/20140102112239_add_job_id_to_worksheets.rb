class AddJobIdToWorksheets < ActiveRecord::Migration
  def change
    add_column :worksheets, :job_id, :integer, default: -1
  end
end
