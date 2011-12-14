# == Schema Information
#
# Table name: study_groups
#
#  id         :integer         not null, primary key
#  school_id  :integer
#  klass      :integer
#  section    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class StudyGroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
