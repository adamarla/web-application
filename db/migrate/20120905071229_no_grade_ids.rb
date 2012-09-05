class NoGradeIds < ActiveRecord::Migration
  # This is an irreversible migration
  def up 
    GradedResponse.graded.each do |m|
      c = m.grade.calibration_id
      m.update_attribute :grade_id, c
    end 
    rename_column :graded_responses, :grade_id, :calibration_id
  end

  def down
  end 
end
