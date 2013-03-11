class AssignUidsToSektions < ActiveRecord::Migration
  def up
    Sektion.where(:uid => nil).each do |sk|
      sk.assign_uid
      sleep 1 # ensure that no two sektions of the same teacher get the same time-stamp
    end 
  end

  def down
  end
end
