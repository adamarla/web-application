class AddJobIdToTestpapers < ActiveRecord::Migration
  def change
    add_column :testpapers, :job_id, :integer, :default => -1
  end
end
