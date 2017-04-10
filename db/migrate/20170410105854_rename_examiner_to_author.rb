class RenameExaminerToAuthor < ActiveRecord::Migration
  def change 
    rename_table :examiners, :authors 
    rename_column :riddles, :examiner_id, :author_id
    rename_column :skills, :examiner_id, :author_id
    add_column :authors, :email, :string

    # Transfer e-mails from Account -> Author table
    Account.where(loggable_type: "Examiner").each do |a| 
      b = Author.where(id: a.loggable_id).first 
      b.update_attribute(:email, a.email) unless b.nil?
    end 

  end 
end
