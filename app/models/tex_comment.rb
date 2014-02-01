# == Schema Information
#
# Table name: tex_comments
#
#  id            :integer         not null, primary key
#  text          :text
#  n_used_self   :integer         default(0)
#  n_used_others :integer         default(0)
#  examiner_id   :integer
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

class TexComment < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :examiner
end
