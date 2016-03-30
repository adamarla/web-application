# == Schema Information
#
# Table name: questions
#
#  id          :integer         not null, primary key
#  uid         :string(20)
#  n_picked    :integer         default(0)
#  created_at  :datetime
#  updated_at  :datetime
#  examiner_id :integer
#  topic_id    :integer
#  difficulty  :integer         default(1)
#  available   :boolean         default(TRUE)
#  potd        :boolean         default(FALSE)
#  num_potd    :integer         default(0)
#

require 'test_helper'

class DbQuestionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

