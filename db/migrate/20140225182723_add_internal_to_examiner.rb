class AddInternalToExaminer < ActiveRecord::Migration
  def change
    add_column :examiners, :internal, :boolean, default: false
    Examiner.all.each do |e| 
      e.update_attributes internal: true
    end 
  end
end
