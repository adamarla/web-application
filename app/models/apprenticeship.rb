# == Schema Information
#
# Table name: apprenticeships
#
#  id         :integer         not null, primary key
#  mentee_id  :integer
#  mentor_id  :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Apprenticeship < ActiveRecord::Base
end
