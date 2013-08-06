# == Schema Information
#
# Table name: videos
#
#  id         :integer         not null, primary key
#  url        :text
#  tutorial   :boolean         default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#  title      :string(70)
#  active     :boolean         default(FALSE)
#  index      :integer         default(-1)
#  history    :boolean         default(FALSE)
#  lecture    :boolean         default(FALSE)
#

class Video < ActiveRecord::Base
  validates :title, :presence => true
  validates :url, :presence => true

  def self.tutorials
    where tutorial: true
  end 

  def self.lectures
    where lecture: true
  end 

  def self.history_lessons
    where history: true
  end

  def self.active
    where active: true
  end

end

