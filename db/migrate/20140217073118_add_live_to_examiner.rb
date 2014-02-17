class AddLiveToExaminer < ActiveRecord::Migration
  def change
    add_column :examiners, :live, :boolean, default: false
  end
end
