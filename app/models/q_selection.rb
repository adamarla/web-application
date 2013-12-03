# == Schema Information
#
# Table name: q_selections
#
#  id          :integer         not null, primary key
#  quiz_id     :integer
#  question_id :integer
#  start_page  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  index       :integer
#  end_page    :integer
#  shadow      :integer
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

class QSelection < ActiveRecord::Base
  belongs_to :quiz
  belongs_to :question

  has_many :graded_responses, dependent: :destroy
  has_many :variants, dependent: :destroy

  # [:all] ~> [:admin, :teacher]
  #attr_accessible 

  def self.on_page(n)
    # Return QSelections that either lie on page 'n' or that span
    # pages including page 'n'
    where('start_page <= ?', n).where('end_page >= ?', n)
  end

  def self.on_topic(n)
    select{ |m| m.question.topic_id == n }
  end

  def prev
    # Returns the QSelection for the last question laid 
    # out on the same page as this one 
    p = QSelection.where(quiz_id: self.quiz_id).where(index: self.index - 1).first
    return (p.nil? ? nil : (p.end_page == self.start_page ? p : nil))
  end

  def next 
    # Returns the QSelection for the next question laid 
    # out on the same page as this one 
    p = QSelection.where(quiz_id: self.quiz_id).where(index: self.index + 1).first
    return (p.nil? ? nil : (p.start_page == self.end_page ? p : nil))
  end

  def shadow?
    return self.shadow unless self.shadow.nil?

    p = self.prev 
    ret = p.nil? ? 0 : ( (((p.shadow? / 100.00) + p.question.length?).modulo(1) * 100).to_i )
    self.update_attribute :shadow, ret
    return ret
  end

  def siblings(dir, same_page = false)
=begin
    Handles all of the following cases 
      1. prior to self - in the whole quiz
      2. prior to self - but only on the same page 
      3. after self - in the whole quiz
      4. after self - on the same page
=end
    previous = dir == :previous # or :next
    a = QSelection.where(quiz_id: self.quiz_id)
    b = previous ? a.where('index < ?', self.index) : a.where('index > ?', self.index)
    return (same_page ? (previous ? b.where(start_page: self.start_page) : b.where(start_page: self.end_page)) : b) 
  end

end
