class SetCountryHueristically < ActiveRecord::Migration
  def up
    Account.where(:loggable_type => 'Teacher', :country => nil).each do |m|
      m.update_attribute(:country, 100) unless m.id == 73 # = india
    end 

    Account.find(73).update_attribute(:country, 230) # US
  end

  def down
  end
end
