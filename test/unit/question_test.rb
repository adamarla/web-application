# == Schema Information
#
# Table name: questions
#
#  id              :integer         not null, primary key
#  uid             :string(255)
#  n_picked        :integer         default(0)
#  created_at      :datetime
#  updated_at      :datetime
#  examiner_id     :integer
#  topic_id        :integer
#  teacher_id      :integer
#  difficulty      :integer         default(1)
#  marks           :integer
#  length          :float
#  answer_key_span :integer
#  calculation_aid :integer         default(0)
#  restricted      :boolean         default(TRUE)
#

require 'test_helper'

class DbQuestionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
