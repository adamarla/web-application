# == Schema Information
#
# Table name: usages
#
#  id                    :integer         not null, primary key
#  date                  :string(30)
#  user_id               :integer
#  time_zone             :string(50)
#  time_on_snippets      :integer         default(0)
#  time_on_questions     :integer         default(0)
#  num_snippets_done     :integer         default(0)
#  num_questions_done    :integer         default(0)
#  time_on_stats         :integer         default(0)
#  num_snippets_clicked  :integer         default(0)
#  num_questions_clicked :integer         default(0)
#

class Usage < ActiveRecord::Base
  # attr_accessible :title, :body
  
  validates :date, presence: true 
  validates :date, uniqueness: { scope: :user_id } 
end
