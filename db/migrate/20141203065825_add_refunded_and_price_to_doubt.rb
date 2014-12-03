class AddRefundedAndPriceToDoubt < ActiveRecord::Migration
  def change
    add_column :doubts, :refunded, :boolean, default: false 
    add_column :doubts, :price, :integer
  end
end
