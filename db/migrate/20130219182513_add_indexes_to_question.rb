class AddIndexesToQuestion < ActiveRecord::Migration
  def change
    add_index :questions, :topic_id
  end
end
