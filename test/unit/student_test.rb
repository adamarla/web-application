# == Schema Information
#
# Table name: students
#
#  id             :integer         not null, primary key
#  guardian_id    :integer
#  first_name     :string(30)
#  last_name      :string(30)
#  created_at     :datetime
#  updated_at     :datetime
#  shell          :boolean         default(FALSE)
#  phone          :string(15)
#  indie          :boolean
#  reward_gredits :integer         default(100)
#  paid_gredits   :integer         default(0)
#

require 'test_helper'

class StudentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
