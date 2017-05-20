# == Schema Information
#
# Table name: activities
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  sku_id       :integer
#  got_right    :integer
#  date         :integer
#  num_attempts :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class Activity < ActiveRecord::Base
  # attr_accessible :date, :got_right, :num_attempts, :sku_id, :user_id

  # this model can be a throway once the entire 'Evident' experiment
  # is complete...
  #
  # got_right - each step a user got right/wrong is represented
  #             by a bit. Examples below:
  #
  # Condition                               binary decimal
  # ======================================================
  # 6-step problem, all steps correct       111111 63
  # 6-step problem, alternate steps correct 101010 42
  # 5-step problem, only first step correct 10000  16
  # 4-step problem, only last step correct  0001   1


end

