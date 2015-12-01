# == Schema Information
#
# Table name: jotd
#
#  id            :integer         not null, primary key
#  uid           :integer
#  joke_id       :integer
#  num_sent      :integer
#  num_failed    :integer
#  num_received  :integer
#  num_opened    :integer
#  num_dismissed :integer
#

class Jotd < ActiveRecord::Base
  # attr_accessible :title, :body
end
