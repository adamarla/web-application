# == Schema Information
#
# Table name: schools
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  street_address :string(255)
#  city           :string(255)
#  state          :string(255)
#  zip_code       :string(255)
#  phone          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  tag            :string(255)
#  board_id       :integer
#  xls            :string(255)
#

require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
