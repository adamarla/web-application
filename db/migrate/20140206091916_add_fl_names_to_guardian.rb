class AddFlNamesToGuardian < ActiveRecord::Migration
  def change
    add_column :guardians, :first_name, :string, :limit => 30
    add_column :guardians, :last_name, :string, :limit => 30
  end
end
