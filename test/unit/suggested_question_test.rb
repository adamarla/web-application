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

require 'test_helper'

class SuggestedQuestionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
