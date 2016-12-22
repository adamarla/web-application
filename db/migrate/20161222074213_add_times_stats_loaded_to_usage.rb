class AddTimesStatsLoadedToUsage < ActiveRecord::Migration
  def change
    add_column :usages, :num_stats_loaded, :integer, default: 0
  end
end
