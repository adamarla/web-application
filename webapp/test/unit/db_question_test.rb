# == Schema Information
#
# Table name: db_questions
#
#  id         :integer         not null, primary key
#  path       :string(255)
#  attempts   :integer         default(0)
#  flags      :integer         default(0)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class DbQuestionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
