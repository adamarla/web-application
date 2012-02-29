# == Schema Information
#
# Table name: syllabi
#
#  id         :integer         not null, primary key
#  course_id  :integer
#  topic_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  difficulty :integer         default(1)
#

require 'test_helper'

class SyllabusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
