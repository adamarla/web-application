class CreateAggrByTopics < ActiveRecord::Migration
  def change
    create_table :aggr_by_topics do |t|
      t.integer :topic_id
      t.integer :aggregator_id
      t.string  :aggregator_type, limit: 20
      t.float   :benchmark
      t.float   :average
      t.integer :attempts

      t.timestamps
    end
  end
end
