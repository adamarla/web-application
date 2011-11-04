# == Schema Information
#
# Table name: q_selections
#
#  id          :integer         not null, primary key
#  quiz_id     :integer
#  question_id :integer
#  page        :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class QSelection < ActiveRecord::Base
  belongs_to :quiz
  belongs_to :question
end
