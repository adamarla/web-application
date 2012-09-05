class NoGradeIds < ActiveRecord::Migration
  # This is an irreversible migration
  def up 
    rename_column :graded_responses, :grade_id, :calibration_id
    # At this time, the calibration_id actually has the old grade_id
    GradedResponse.graded.each do |m|
      g = Grade.where(:id => m.calibration_id).first
      c = g.nil? ? nil : g.calibration_id 
      m.update_attribute :calibration_id, c 
    end 
  end

  def down
  end 
end
