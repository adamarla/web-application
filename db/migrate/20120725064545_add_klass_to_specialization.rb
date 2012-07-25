class AddKlassToSpecialization < ActiveRecord::Migration
  def change
    add_column :specializations, :klass, :integer
  end
end
