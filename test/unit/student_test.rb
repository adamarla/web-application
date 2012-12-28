# == Schema Information
#
# Table name: students
#
#  id          :integer         not null, primary key
#  guardian_id :integer
#  school_id   :integer
#  first_name  :string(30)
#  last_name   :string(30)
#  created_at  :datetime
#  updated_at  :datetime
#  klass       :integer
#

require 'test_helper'

class StudentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
