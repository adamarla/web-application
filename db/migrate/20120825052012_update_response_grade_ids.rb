class UpdateResponseGradeIds < ActiveRecord::Migration
=begin
  This is an *irreversible* migration - partly because of its mechanics
  but largely because of design

  We don't want to reverse this migration and go back to the old, less
  precise scheme of grades mapping to catch-all yardsticks. We want
  grades to map to calibrations which capture not just the bottomline 
  but also the reasons leading upto that bottomline 
=end
  def up
    # Mapping of old yardsticks to new calibrations. Worked out manually
    # because it entails human judgement. The hash is of the form 
    # { :old yardstick => :new calibration }

    mapping = { 
      1 => 3, 
      2 => 19,
      3 => 6,
      4 => 20,
      5 => 8,
      6 => 22,
      7 => 10,
      8 => 4,
      9 => 18,
      10 => 9,
      12 => 21, 
      13 => 1
    } 
  
    graded = GradedResponse.graded
    Teacher.select(:id).map(&:id).each do |t|
      teacher_grades = Grade.where(:teacher_id => t)

      mapping.each do |old, neu| # new is a reserved word. So, the German version of it
        old_g = teacher_grades.where(:yardstick_id => old).first
        new_g = teacher_grades.where(:calibration_id => neu).first

        next if old_g.nil? || new_g.nil?

        graded.where(:grade_id => old_g.id).each do |m|
          m.update_attribute :grade_id, new_g.id
        end # of update  
      end # of mapping 
    end # of teacher

    # Now, delete old yardsticks and every associated grade 
    Yardstick.where(:id => [*1..13]).each do |m|
      m.destroy
    end

  end

  def down
  end
end
