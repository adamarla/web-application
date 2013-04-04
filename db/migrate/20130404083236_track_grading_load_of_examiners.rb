class TrackGradingLoadOfExaminers < ActiveRecord::Migration
  
  # The values stored in these two new columns can be inferred - but only 
  # by traversing over the whole GradedResponse table - which is kinda large
  # Two dinky little columns is therefore acceptable level of fat
  def up
    add_column :examiners, :n_assigned, :integer, :default => 0
    add_column :examiners, :n_graded, :integer, :default => 0

    # For existing examiners, update the two new columns w/ historical data
    for e in Examiner.all
      all = GradedResponse.assigned_to(e.id)
      graded = all.graded
      e.update_attributes :n_assigned => all.count, :n_graded => graded.count
    end
  end

  def down 
    remove_column :examiners, :n_assigned
    remove_column :examiners, :n_graded
  end 

end
