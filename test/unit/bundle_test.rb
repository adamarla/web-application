# == Schema Information
#
# Table name: bundles
#
#  id            :integer         not null, primary key
#  uid           :string(50)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  signature     :string(20)
#  auto_download :boolean         default(FALSE)
#

require 'test_helper'

class BundleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
