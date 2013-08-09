# == Schema Information
#
# Table name: lectures
#
#  id          :integer         not null, primary key
#  title       :string(70)
#  description :text
#  history     :boolean         default(FALSE)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Lecture < ActiveRecord::Base
  # attr_accessible :title, :body
end
