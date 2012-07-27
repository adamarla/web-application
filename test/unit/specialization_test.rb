# == Schema Information
#
# Table name: specializations
#
#  id         :integer         not null, primary key
#  teacher_id :integer
#  subject_id :integer
#  created_at :datetime
#  updated_at :datetime
#  klass      :integer
#

require 'test_helper'

class SpecializationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
