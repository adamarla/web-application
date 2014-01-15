class ConnectResponseToWorksheet < ActiveRecord::Migration
  def up
    add_column :graded_responses, :worksheet_id, :integer
    add_index :graded_responses, :worksheet_id

    exams = Exam.all.map(&:id).uniq
    exams.each do |e|
      Worksheet.where(exam_id: e).each do |w|
        GradedResponse.where(exam_id: e, student_id: w.student_id).each do |g|
          g.update_attribute :worksheet_id, w.id
        end
      end
    end

    remove_column :graded_responses, :exam_id
  end

  def down
    add_column :graded_responses, :exam_id, :integer
    add_index :graded_responses, :exam_id

    Worksheet.where('exam_id IS NOT ?', nil).each do |w|
      GradedResponse.where(worksheet_id: w.id).each do |g|
        g.update_attribute :exam_id, w.exam_id
      end
    end

    remove_column :graded_responses, :worksheet_id
  end
end
