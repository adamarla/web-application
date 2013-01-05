class SyncReq2 < ActiveRecord::Migration
  def up
    # remove :text from some requirements 
    Requirement.where(:cogent => true, :posn => 3).first.update_attribute(:text, "")
    
    # edit some existing ones 
    Requirement.where(:other =>true, :posn => 4).first.update_attributes( 
    :bottomline => "Elaborate", :text => "Show more steps", :weight => -1)
  end

  def down
  end
end
