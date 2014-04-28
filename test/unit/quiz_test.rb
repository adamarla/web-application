# == Schema Information
#
# Table name: quizzes
#
#  id                    :integer         not null, primary key
#  teacher_id            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  num_questions         :integer
#  name                  :string(70)
#  subject_id            :integer
#  total                 :integer
#  span                  :integer
#  parent_id             :integer
#  job_id                :integer         default(-1)
#  uid                   :string(40)
#  version               :string(10)
#  shadows               :string(255)
#  page_breaks_after     :string(255)
#  switch_versions_after :string(255)
#

require 'test_helper'

class QuizTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
