# == Schema Information
#
# Table name: examiners
#
#  id            :integer         not null, primary key
#  num_contested :integer         default(0)
#  created_at    :datetime
#  updated_at    :datetime
#  secret_key    :string(255)
#  is_admin      :boolean         default(FALSE)
#  first_name    :string(255)
#  last_name     :string(255)
#

class Examiner < ActiveRecord::Base
  has_one :account, :as => :loggable
  has_many :graded_responses

  # [:all] ~> [:admin]
  # [:secret_key] ~> [:examiner] 
  # [:num_contested] ~> [:student]
  #attr_accessible :num_contested
  before_create :set_secret_key

  def name 
    return "#{self.first_name} #{self.last_name} (#{self.account.username})"
  end 

  def generate_username
    # Usernames are generated using the first & last names and the time of 
    # record creation - but with a slight difference depending on what role
    # the person has 
    #
    # For example, below would be the usernames for a person called Richard Feynman
    #   (if an examiner) : richardf
    #   (if an admin) : rfeynman
    # The scheme is similar to that used for Teachers and Students. Those just have 
    # an additional time-stamp embedded in their usernames

    username = nil 
    unless (self.first_name.nil? || self.last_name.nil?) 
      username = (self.is_admin) ? "#{self.first_name[0]}#{self.last_name}" : 
                                   "#{self.first_name}#{self.last_name[0]}"
      # Check for username conflict. If there is, then for the new examiner, default
      # to "#{first_name}.#{last_name}"
      unless Account.where(:username => username).empty? 
        username = "#{self.first_name}.#{self.last_name}" 
      end 
    end 
    return username.downcase 
  end 

  private 
    def set_secret_key 
      x = rand(36**16).to_s(36).rjust(16,"0")
      y = rand(36**16).to_s(36).rjust(16,"0")
      self.secret_key = x + y
    end 

end
