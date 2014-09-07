# == Schema Information
#
# Table name: commentaries
#
#  id             :integer         not null, primary key
#  question_id    :integer
#  tex_comment_id :integer
#

class Commentary < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :question 
  belongs_to :tex_comment

  validates :tex_comment_id, uniqueness: { scope: :question_id }
end
