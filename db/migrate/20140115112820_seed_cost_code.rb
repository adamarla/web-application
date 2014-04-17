class SeedCostCode < ActiveRecord::Migration
  def up
    CostCode.create(description: "Assessment Service", subscription: true)
    CostCode.create(description: "Assessment Platform", subscription: true)
    CostCode.create(description: "Course Credit", subscription: false)
    CostCode.create(description: "Parental Access", subscription: true)
    CostCode.create(description: "Assessment Service Demo", subscription: false)
    CostCode.create(description: "Assessment Platform Demo", subscription: false)
  end

  def down
  end
end
