class TrimQuestionModel < ActiveRecord::Migration
  def up 
    remove_column :questions, :suggestion_id
    remove_column :questions, :marks
    remove_column :questions, :answer_key_span 
    remove_column :questions, :auditor
    remove_column :questions, :audited_on
    remove_column :questions, :calculation_aid
    remove_column :questions, :n_codices
    remove_column :questions, :codices
    remove_column :questions, :length
  end 

  def down 
  end 
end
