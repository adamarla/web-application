class AddTopicIdToDbQuestion < ActiveRecord::Migration
  def change
    add_column :db_questions, :topic_id, :integer
  end
end
