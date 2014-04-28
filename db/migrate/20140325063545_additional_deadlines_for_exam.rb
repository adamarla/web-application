class AdditionalDeadlinesForExam < ActiveRecord::Migration
  def change 
    add_column :exams, :submit_by, :datetime
    add_column :exams, :regrade_by, :datetime
    add_column :exams, :dist_scheme, :string
  end 
end
