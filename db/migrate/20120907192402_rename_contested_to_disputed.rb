class RenameContestedToDisputed < ActiveRecord::Migration
  def change 
    rename_column :examiners, :num_contested, :disputed
    rename_column :graded_responses, :contested, :disputed
  end
end
