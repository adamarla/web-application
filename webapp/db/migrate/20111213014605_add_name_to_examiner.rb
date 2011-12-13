class AddNameToExaminer < ActiveRecord::Migration
  def change
    add_column :examiners, :first_name, :string
    add_column :examiners, :last_name, :string
  end
end
