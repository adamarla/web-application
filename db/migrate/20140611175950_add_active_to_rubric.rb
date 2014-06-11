class AddActiveToRubric < ActiveRecord::Migration
  def change
    add_column :rubrics, :active, :boolean, default: false
  end
end
