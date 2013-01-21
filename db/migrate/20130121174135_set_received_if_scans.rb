class SetReceivedIfScans < ActiveRecord::Migration
  def up
    AnswerSheet.all.each do |m| 
      has_scans = GradedResponse.of_student(m.student_id).in_testpaper(m.testpaper_id).without_scan.count == 0
      m.update_attribute :received, has_scans if has_scans 
    end 
  end

  def down
    AnswerSheet.all.each do |m| 
      m.update_attribute :received, false 
    end 
  end
end
