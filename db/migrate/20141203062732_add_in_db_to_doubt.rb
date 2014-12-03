class AddInDbToDoubt < ActiveRecord::Migration
  def change
    add_column :doubts, :in_db, :boolean, default: false
  end
end
