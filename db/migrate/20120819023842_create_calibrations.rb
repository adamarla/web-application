class CreateCalibrations < ActiveRecord::Migration
  def change
    create_table :calibrations do |t|
      t.integer :insight_id
      t.integer :formulation_id
      t.integer :calculation_id
      t.integer :mcq_id
      t.integer :allotment
    end
  end
end
