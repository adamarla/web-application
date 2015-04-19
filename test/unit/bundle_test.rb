# == Schema Information
#
# Table name: bundles
#
#  id         :integer         not null, primary key
#  title      :string(150)
#  package_id :integer
#  uid        :string(50)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'test_helper'

class BundleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
