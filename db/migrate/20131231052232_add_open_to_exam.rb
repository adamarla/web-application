class AddOpenToExam < ActiveRecord::Migration
  def up
    add_column :exams, :open, :boolean, default: true
    Exam.all.each do |e| 
      e.update_attribute :open, false
    end 
  end

  def down
    remove_column :exams, :open
  end 
end
