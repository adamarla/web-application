class AddXlsToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :xls, :string
  end
end
