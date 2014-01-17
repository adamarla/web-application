class SeedCostCode < ActiveRecord::Migration
  def up
    CostCode.create(description: "Assessment Service", subscription: true)
    CostCode.create(description: "Assessment Platform", subscription: true)
    CostCode.create(description: "Course Credit", subscription: false)
    CostCode.create(description: "Supervisory Access", subscription: true)
  end

  def down
  end
end
