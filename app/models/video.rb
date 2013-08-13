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
  validates :url, presence: true 
  validates :url, uniqueness: true

  belongs_to :watchable, polymorphic: true

  def self.active
    where active: true
  end

end

