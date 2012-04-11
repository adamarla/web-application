# == Schema Information
#
# Table name: subparts
#
#  id            :integer         not null, primary key
#  question_id   :integer
#  mcq           :boolean         default(FALSE)
#  half_page     :boolean         default(FALSE)
#  full_page     :boolean         default(TRUE)
#  marks         :integer
#  multi_correct :boolean         default(FALSE)
#

require 'test_helper'

class SubpartTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
