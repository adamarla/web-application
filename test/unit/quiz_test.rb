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
#  subject_id    :integer
#  total         :integer
#  span          :integer
#  parent_id     :integer
#  job_id        :integer         default(-1)
#

require 'test_helper'

class QuizTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
