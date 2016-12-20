class ChargePerMonthInWtp < ActiveRecord::Migration
  def change 
    rename_column :wtps, :price_per_week, :price_per_month
  end 
end
