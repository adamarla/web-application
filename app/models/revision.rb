# == Schema Information
#
# Table name: revisions
#
#  id          :integer         not null, primary key
#  question_id :integer
#  latex       :boolean         default(FALSE)
#  hints       :boolean         default(FALSE)
#

class Revision < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :question

  def self.before(rvn_id) 
    where('id < ?', rvn_id)
  end 

  def self.after(rvn_id)
    where('id > ?', rvn_id)
  end 

  def self.to_question(qid)
    where(question_id: qid)
  end 

  def self.latex
    where(latex: true)
  end 

  def self.hints 
    where(hints: true)
  end 

end
