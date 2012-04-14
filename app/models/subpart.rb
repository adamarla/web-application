# == Schema Information
#
# Table name: subparts
#
#  id          :integer         not null, primary key
#  question_id :integer
#  mcq         :boolean         default(FALSE)
#  half_page   :boolean         default(FALSE)
#  full_page   :boolean         default(TRUE)
#  marks       :integer
#  index       :integer
#  offset      :integer
#

class Subpart < ActiveRecord::Base
  belongs_to :question
  has_many :graded_responses

  def name?(quiz_id)
    # What a subpart is called depends on the quiz in which the parent 
    # question is instantiated. The same question could be Q2 in one 
    # quiz and Q7 in another
    parent = self.question
    id = QSelection.where(:quiz_id => quiz_id, :question_id => parent.id).map(&:index).first
    nparts = parent.num_parts?
    if nparts == 0
      return "Ques. #{id}"
    else
      c = [*'A'..'K'][self.index]
      return "Ques. #{id}#{c}"
    end
  end

end
