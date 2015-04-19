# == Schema Information
#
# Table name: bundle_questions
#
#  id          :integer         not null, primary key
#  bundle_id   :integer
#  question_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class BundleQuestion < ActiveRecord::Base
  # attr_accessible :bundle_id, :question_id
  belongs_to :bundle
  belongs_to :question
end
