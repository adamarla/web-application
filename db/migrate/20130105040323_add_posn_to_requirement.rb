class AddPosnToRequirement < ActiveRecord::Migration
  def change
    # Saw problems when migrating in earlier migrations 
    # due to absence of :posn. Hence, added :posn when 
    # requirement table is first created 

    # However, not git rm'ing the migration. Just emptying it out
  end

end
