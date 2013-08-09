# == Schema Information
#
# Table name: videos
#
#  id             :integer         not null, primary key
#  url            :text
#  created_at     :datetime
#  updated_at     :datetime
#  active         :boolean         default(FALSE)
#  watchable_id   :integer
#  watchable_type :string(20)
#

class Video < ActiveRecord::Base
  validates :title, :presence => true
  validates :url, :presence => true

  belongs_to :watchable, polymorphic: true

  def self.active
    where active: true
  end

end

