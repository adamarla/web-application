class TrackMobileOptionUptake < ActiveRecord::Migration
  def change 
    add_column :behaviours, :n_answers, :integer, default: 0
    add_column :behaviours, :n_solutions, :integer, default: 0
  end 
end
