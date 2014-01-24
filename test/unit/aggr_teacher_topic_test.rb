# == Schema Information
#
# Table name: aggr_teacher_topics
#
#  id             :integer         not null, primary key
#  teacher_id     :integer
#  topic_id       :integer
#  benchmark      :float
#  average_score  :float
#  basis_attempts :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

require 'test_helper'

class AggrTeacherTopicTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
