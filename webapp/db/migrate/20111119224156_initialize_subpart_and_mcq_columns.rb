class InitializeSubpartAndMcqColumns < ActiveRecord::Migration
  def change 
    GradeDescription.reset_column_information 
    GradeDescription.all.each { |g| g.update_attributes :mcq => false, :subpart => false }
  end

end
