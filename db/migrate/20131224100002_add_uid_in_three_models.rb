class AddUidInThreeModels < ActiveRecord::Migration
  def change 
    add_column :quizzes, :uid, :string, limit: 40
    add_column :worksheets, :uid, :string, limit: 40
    add_column :exams, :uid, :string, limit: 40
  end 
end
