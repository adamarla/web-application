# == Schema Information
#
# Table name: bundle_questions
#
#  id          :integer         not null, primary key
#  bundle_id   :integer
#  question_id :integer
#  label       :string(8)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

require 'test_helper'

class BundleQuestionsTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
