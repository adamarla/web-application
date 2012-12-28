# == Schema Information
#
# Table name: schools
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  street_address :string(255)
#  city           :string(40)
#  state          :string(40)
#  zip_code       :string(15)
#  phone          :string(20)
#  created_at     :datetime
#  updated_at     :datetime
#  tag            :string(40)
#  board_id       :integer
#  xls            :string(255)
#

require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
