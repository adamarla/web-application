# == Schema Information
#
# Table name: subparts
#
#  id            :integer         not null, primary key
#  question_id   :integer
#  mcq           :boolean         default(FALSE)
#  half_page     :boolean         default(FALSE)
#  full_page     :boolean         default(TRUE)
#  marks         :integer
#  index         :integer
#  relative_page :integer
#  few_lines     :boolean         default(FALSE)
#

class Subpart < ActiveRecord::Base
  belongs_to :question
  has_many :graded_responses

  def on_page? (n,quiz)
    # Returns true if this subpart is on page 'n' of 'quiz'
    # 'n' can be an array of page numbers too, like [4,7,9] - in which case
    # the method would return true if the subpart is on either of the pages
    # in the given quiz

    page = self.on_page_in? quiz 
    return false if page < 0
    return (n.class == Array) ? n.include?(page) : (page == n)
  end # of method

  def on_page_in?(quiz_id)
=begin
    Returns the *absolute* page # on which this subpart is in the passed quiz
    Remember, we cannot store which page a question is on as a property of the
    question/subpart because where it is depends on who included it
=end
    m = QSelection.where(:question_id => self.question_id, :quiz_id => quiz_id)
    return -1 if m.empty? 

    page = m.first.start_page + self.relative_page
    return page
  end 

  def name_if_in?(quiz)
    qsel = QSelection.where(:quiz_id => quiz, :question_id => self.question_id).first
    multi = self.question.num_parts? > 0

    if multi
      c = [*'A'..'Z'][self.index]
      return "Q.#{qsel.index}-#{c}"
    else
      return "Q.#{qsel.index}"
    end
  end 

  def self.in_quiz(quiz)
    # Returns the ordered list - by position in the quiz - of subparts in a quiz
    qids = QSelection.where(:quiz_id => quiz).order(:index).map(&:question_id)
    where(:question_id => qids).sort{ |m,n| 
      m.index * qids.index(m.question_id) <=> n.index * qids.index(n.question_id) 
    }.sort { |m,n| 
      qids.index(m.question_id) <=> qids.index(n.question_id) 
    } 
    #where(:question_id => qids).sort{ |m,n| m.index <=> n.index }.sort{ |m,n| qids.index(m.question_id) <=> qids.index(n.question_id) }
  end

end
