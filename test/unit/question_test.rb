# == Schema Information
#
# Table name: riddles
#
#  id               :integer         not null, primary key
#  type             :string(50)
#  original_id      :integer
#  chapter_id       :integer
#  parent_riddle_id :integer
#  language_id      :integer         default(1)
#  difficulty       :integer         default(20)
#  num_attempted    :integer         default(0)
#  num_completed    :integer         default(0)
#  num_correct      :integer         default(0)
#  author_id        :integer
#  has_svgs         :boolean         default(FALSE)
#  created_at       :datetime
#  updated_at       :datetime
#  has_draft        :boolean         default(FALSE)
#

require 'test_helper'

class DbQuestionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

