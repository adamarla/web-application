class AddQuizIdToWorksheet < ActiveRecord::Migration
  def up
    add_column :worksheets, :quiz_id, :integer 
    add_index :worksheets, :quiz_id 

    Worksheet.all.each do |w| 
      w.update_attribute :quiz_id, w.exam.quiz_id
    end 
  end

  def down 
    remove_column :worksheets, :quiz_id
  end 
end
