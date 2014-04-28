class SeedRateCode < ActiveRecord::Migration
  def up
    RateCode.create(cost_code_id: 3, value: 2, currency: "USD")
    RateCode.create(cost_code_id: 3, value: 100, currency: "INR")
  end

  def down
  end
end
