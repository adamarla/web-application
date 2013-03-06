class TrimSchool < ActiveRecord::Migration
  def up
    remove_column :schools, :street_address
    remove_column :schools, :city
    remove_column :schools, :state
    remove_column :schools, :tag
    remove_column :schools, :board_id
    add_column :schools, :country_id, :integer
  end

  def down
    add_column :schools, :street_address, :string
    add_column :schools, :city, :string, :limit => 40
    add_column :schools, :state, :string, :limit => 40
    add_column :schools, :tag, :string, :limit => 40
    add_column :schools, :board_id, :integer
  end
end
