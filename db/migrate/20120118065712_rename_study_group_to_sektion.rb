class RenameStudyGroupToSektion < ActiveRecord::Migration
  def change
    rename_table :study_groups, :sektions
  end
end
