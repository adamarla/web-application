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

  def on_page? (n,quiz)
    # Returns true if this subpart is on page 'n' of 'quiz'
    # 'n' can be an array of page numbers too, like [4,7,9] - in which case
    # the method would return true if the subpart is on either of the pages
    # in the given quiz

    s = QSelection.where(:question_id => self.question_id, :quiz_id => quiz)
    return false if s.empty? 

    start_pg = s.select(:start_page).first.start_page
    pg = start_pg + self.offset

    if n.class == Array
      return n.include? pg
    else 
      return pg == n
    end
  end # of method

  def self.in_quiz(quiz)
    where(:question_id => QSelection.where(:quiz_id => quiz).map(&:question_id))
  end

end
