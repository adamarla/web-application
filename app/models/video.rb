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
#  sublime_uid    :string(20)
#  sublime_title  :string(70)
#

class Video < ActiveRecord::Base
  validates :sublime_uid, presence: true
  validates :sublime_uid, uniqueness: true

  belongs_to :watchable, polymorphic: true

  def self.active
    where active: true
  end

end

