class AddMobileToResponse < ActiveRecord::Migration
  def change
    add_column :graded_responses, :mobile, :boolean, default: false
  end
end
