class AddPriceToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :price, :decimal, precision: 5, scale: 2
  end
end
