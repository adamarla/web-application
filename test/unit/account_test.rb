# == Schema Information
#
# Table name: accounts
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(128)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  loggable_id            :integer
#  loggable_type          :string(20)
#  active                 :boolean         default(TRUE)
#  username               :string(50)
#  country                :integer         default(100)
#  state                  :string(40)
#  city                   :string(40)
#  postal_code            :string(10)
#  latitude               :float
#  longitude              :float
#  authentication_token   :string(255)
#  login_allowed          :boolean
#  mimics_admin           :boolean         default(FALSE)
#  phone                  :string(15)
#  mobile                 :string(255)
#

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
