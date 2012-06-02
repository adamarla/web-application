# == Schema Information
#
# Table name: countries
#
#  id           :integer         not null, primary key
#  name         :string(255)
#  alpha_2_code :string(255)
#

class Country < ActiveRecord::Base
end
