class AddScanAvailableToGradedResponse < ActiveRecord::Migration
  def up
    add_column :graded_responses, :scan_available, :boolean, :default => false
    remove_column :graded_responses, :scanned_image
  end

  def down
    remove_column :graded_responses, :scan_available
    add_column :graded_responses, :scanned_image, :string
  end
end
