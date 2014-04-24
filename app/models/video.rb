# == Schema Information
#
# Table name: videos
#
#  id             :integer         not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  active         :boolean         default(FALSE)
#  watchable_id   :integer
#  watchable_type :string(20)
#  uid            :string(20)
#

class Video < ActiveRecord::Base
  validates :uid, presence: true
  belongs_to :watchable, polymorphic: true

  def self.active
    where active: true
  end

end # of class

