class AddResponseIdToDoodle < ActiveRecord::Migration
  def change
    add_column :doodles, :graded_response_id, :integer
  end
end
