# == Schema Information
#
# Table name: videos
#
#  id            :integer         not null, primary key
#  url           :string(255)
#  restricted    :boolean         default(TRUE)
#  instructional :boolean         default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#  title         :string(255)
#

class Video < ActiveRecord::Base
  validates :title, :presence => true
  validates :url, :presence => true
end
