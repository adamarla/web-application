class FinishSpringCleanApril17 < ActiveRecord::Migration
  def up
    [ :analgesics, 
      :notif_responses, 
      :potd, 
      :topics, 
      :verticals ].each do |name| 

      drop_table name if ActiveRecord::Base.connection.table_exists?(name)
    end 
  end

  def down
  end
end
