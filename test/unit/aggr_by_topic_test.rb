# == Schema Information
#
# Table name: aggr_by_topics
#
#  id              :integer         not null, primary key
#  topic_id        :integer
#  aggregator_id   :integer
#  aggregator_type :string(20)
#  benchmark       :float
#  average         :float
#  attempts        :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

require 'test_helper'

class AggrByTopicTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
