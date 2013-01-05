class AddPosnToRequirement < ActiveRecord::Migration
  def change
    add_column :requirements, :posn, :integer
    # At this time, there already are some requirements in the DB - but without posn
    # This initial set was, however, added in some order. Capture just that when determining
    # their relative posni ( 1-indexed ). For subsequent requirements, determine the 
    # relative posn before_save 
    # Note: Anything about a requirement my change in the future - but never its posn!!

    [:honest, :cogent, :complete, :other].each do |m|
      r = Requirement.where(m => true).order(:id).each_with_index do |n,j|
        n.update_attribute :posn, (j + 1)
      end
    end 

  end
end
