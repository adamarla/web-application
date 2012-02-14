class StorePathToScanInGradedResponse < ActiveRecord::Migration
  def up
    change_table :graded_responses do |t|
      t.change :scan_available, :string, :default => nil
      t.rename :scan_available, :scan
    end
  end

  def down
    change_table :graded_responses do |t|
      t.remove :scan
      t.boolean :scan_available, :default => false
    end
  end
end
