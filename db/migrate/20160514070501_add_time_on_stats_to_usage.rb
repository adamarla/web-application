class AddTimeOnStatsToUsage < ActiveRecord::Migration
  def change
    add_column :usages, :time_on_stats, :integer, default: 0
  end
end
