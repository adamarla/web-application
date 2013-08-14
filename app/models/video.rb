# == Schema Information
#
# Table name: videos
#
#  id             :integer         not null, primary key
#  html           :text
#  created_at     :datetime
#  updated_at     :datetime
#  active         :boolean         default(FALSE)
#  watchable_id   :integer
#  watchable_type :string(20)
#

class Video < ActiveRecord::Base
  validates :html, presence: true 
  validates :html, uniqueness: true

  belongs_to :watchable, polymorphic: true

  def self.active
    where active: true
  end

end

