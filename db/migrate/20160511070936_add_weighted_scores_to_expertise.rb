class AddWeightedScoresToExpertise < ActiveRecord::Migration
  def change
    add_column :expertise, :weighted_tested, :float, default: 0
    add_column :expertise, :weighted_correct, :float, default: 0
  end
end
