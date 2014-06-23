# == Schema Information
#
# Table name: doodles
#
#  id                 :integer         not null, primary key
#  examiner_id        :integer
#  feedback           :integer         default(0)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  graded_response_id :integer
#

class Doodle < ActiveRecord::Base
  # attr_accessible :examiner_id, :feedback
  belongs_to :graded_response
  has_many :remarks, dependent: :destroy

  def annotate(comments) 
    TexComment.record(comments, self.examiner_id, self.graded_response_id, self.id)
  end 

  def grade(criterion_ids)
    g = self.graded_response 
    rubric = Rubric.find g.worksheet.exam.rubric_id? 
    fdb, penalty = rubric.fdb_and_penalty_given criterion_ids 
    self.update_attribute :feedback, fdb # we don't store the marks for doodles 
  end 

end
