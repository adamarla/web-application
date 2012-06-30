# == Schema Information
#
# Table name: suggested_questions
#
#  id            :integer         not null, primary key
#  suggestion_id :integer
#  question_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class SuggestedQuestion < ActiveRecord::Base

  belongs_to :suggestion
  
end
