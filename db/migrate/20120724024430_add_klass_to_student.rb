class AddKlassToStudent < ActiveRecord::Migration
  def change
    add_column :students, :klass, :integer
  end
end
