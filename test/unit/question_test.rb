# == Schema Information
#
# Table name: questions
#
#  id             :integer         not null, primary key
#  path           :string(255)
#  attempts       :integer         default(0)
#  created_at     :datetime
#  updated_at     :datetime
#  examiner_id    :integer
#  micro_topic_id :integer
#  teacher_id     :integer
#  mcq            :boolean         default(FALSE)
#  multi_correct  :boolean         default(FALSE)
#  multi_part     :boolean         default(FALSE)
#  num_parts      :integer
#  difficulty     :integer         default(1)
#  half_page      :boolean         default(FALSE)
#  full_page      :boolean         default(TRUE)
#

require 'test_helper'

class DbQuestionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
