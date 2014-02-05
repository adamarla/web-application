# == Schema Information
#
# Table name: contracts
#
#  id                 :integer         not null, primary key
#  school_id          :integer
#  start_date         :date
#  duration           :integer
#  bill_cycle         :integer
#  start_day_of_month :integer
#  rate_code_id       :integer
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  grade_level        :integer
#  num_students       :integer
#  subject_id         :integer
#

class Contract < ActiveRecord::Base
  belongs_to :school

  after_create :find_day_of_month

  private
  
    def find_day_of_month
      start_day_of_month = start_date.day > 28 ? 28 : start_date.day
    end

end
