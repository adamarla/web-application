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
  has_many :tryouts
  has_many :hints, dependent: :destroy

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

  def siblings(dir = :previous)
=begin
    Returns the other previous OR next subparts that make up the parent question
=end
    previous = dir == :previous # or :next
    b = Subpart.where(question_id: self.question_id)
    return ( previous ? b.where('index < ?', self.index) : b.where('index > ?', self.index) )
  end

  def length?
    return (self.mcq || self.few_lines ? 0.25 : (self.half_page ? 0.5 : 1))
  end

  def comments 
    # Returns every ** non-trivial ** comment ever written by any examiner 
    # for this subpart in ** any quiz **  
    cousins = Tryout.graded.where(subpart_id: self.id)
    remarks = Remark.where(tryout_id: cousins.map(&:id).uniq)
   
    # Show the most used TeX comments first
    a = TexComment.where(id: remarks.map(&:tex_comment_id).uniq).order(:n_used).reverse_order
    tex = a.select{ |m| !m.trivial? }
    return tex
  end 

  def hints 
    return Hint.where(subpart_id: self.id).order(:index)
  end 

  def self.in_quiz(quiz)
    # Returns the ordered list - by position in the quiz - of subparts in a quiz

    questions = QSelection.where(:quiz_id => quiz).order(:index).map(&:question)
    questions.map{ |m| m.subparts.order(:index) }.flatten 
  end

end
