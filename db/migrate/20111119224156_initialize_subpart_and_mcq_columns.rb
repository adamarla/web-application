class InitializeSubpartAndMcqColumns < ActiveRecord::Migration
  class GradeDescription < ActiveRecord::Base ; end 
  def change 
    GradeDescription.reset_column_information 
    GradeDescription.all.each { |g| g.update_attributes :mcq => false, :subpart => false }
  end

end
