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

end
