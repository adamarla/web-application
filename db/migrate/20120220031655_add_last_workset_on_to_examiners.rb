class AddLastWorksetOnToExaminers < ActiveRecord::Migration
  def change
    add_column :examiners, :last_workset_on, :datetime
  end
end
