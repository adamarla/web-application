# == Schema Information
#
# Table name: questions
#
#  id             :integer         not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  favourite      :boolean         default(FALSE)
#  db_question_id :integer
#  teacher_id     :integer
#  times_used     :integer         default(0)
#

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
