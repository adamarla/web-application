# == Schema Information
#
# Table name: schools
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  zip_code   :string(15)
#  phone      :string(20)
#  created_at :datetime
#  updated_at :datetime
#  xls        :string(255)
#  country_id :integer
#  uid        :string(10)
#

require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
