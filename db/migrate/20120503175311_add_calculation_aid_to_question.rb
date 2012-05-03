class AddCalculationAidToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :calculation_aid, :integer, :default => 0
  end
end
