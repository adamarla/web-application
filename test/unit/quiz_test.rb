# == Schema Information
#
# Table name: quizzes
#
#  id            :integer         not null, primary key
#  teacher_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  num_questions :integer
#  name          :string(70)
#  klass         :integer
#  subject_id    :integer
#  atm_key       :string(20)
#  total         :integer
#  span          :integer
#

require 'test_helper'

class QuizTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
