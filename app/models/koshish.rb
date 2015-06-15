# == Schema Information
#
# Table name: koshishein
#
#  id           :integer         not null, primary key
#  pupil_id     :integer
#  question_id  :integer
#  seen_options :boolean         default(FALSE)
#  num_wrong    :integer         default(0)
#  got_right    :boolean
#  max_opened   :integer         default(0)
#  max_time     :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class Koshish < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :pupil 
  validates :num_wrong, numericality: { only_integer: true, less_than: 5 } # [0,4]
  validates :max_opened, numericality: { only_integer: true, less_than: 7 } # [0,6]
end
