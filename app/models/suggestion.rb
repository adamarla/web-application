# == Schema Information
#
# Table name: suggestions
#
#  id            :integer         not null, primary key
#  teacher_id    :integer
#  examiner_id   :integer
#  completed     :boolean         default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#  filesignature :string(255)
#

class Suggestion < ActiveRecord::Base
  
  has_many :suggested_questions, dependent: :destroy
  belongs_to :teacher  
  
  def self.unassigned
    where(:examiner_id => nil)
  end  
  
  def complete
    #update record
    #send email to teacher from examiner
  end

  def outstanding?
    #returns outstanding questions that have yet to be
    #incorporated as part of this suggestion
  end
  
  def as_json(*args)
    hash = super(*args)
    teacher = Teacher.find @teacher_id
    puts "Suggestion.as_json {#teacher.name}"
    hash[:name] = teacher.print_name 
  end
  

  EMAIL_TEXT = "Dear teacher_name, Thank you for providing the questions." 
end
