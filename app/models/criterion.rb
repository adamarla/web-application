# == Schema Information
#
# Table name: criteria
#
#  id          :integer         not null, primary key
#  text        :string(255)
#  penalty     :integer         default(0)
#  account_id  :integer
#  standard    :boolean         default(TRUE)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  red_flag    :boolean         default(FALSE)
#  orange_flag :boolean         default(FALSE)
#  shortcut    :string(1)
#

class Criterion < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :text, presence: true
  validates :penalty, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :shortcut, uniqueness: true, if: :has_shortcut

  def self.standard
    where(standard: true)
  end 

  def self.available_shortcuts
    all = [*'A'..'Z'] + [*'1'..'9']
    reserved = ['H','R','W','U','F','S','L']
    used = Criterion.where(standard: true).map(&:shortcut).select{ |k| !k.nil? }
    return all - reserved - used 
  end 

  def reward? 
    return (100 - self.penalty)
  end 

  def perception? 
    # return :red if self.red_flag? 
    # n = self.num_stars?
    # return ( n < 3 ? :light : ( n == 3 ? :med : :dark ) )
    return (self.red_flag ? :red : (self.orange_flag ? :orange : :green))
  end 

  def badge? 
    return 'icon-flag red' if self.red_flag
    return 'icon-flag orange' if self.orange_flag
    n = self.num_stars? 
    return (n < 4 ? 'icon-tag' : 'icon-thumbs-up')
    # return (n < 3 ? 'icon-thumbs-down' : ( n < 5 ? 'icon-tag' : 'icon-thumbs-up'))
  end 

  def shortcut? 
    self.shortcut.nil? ? '' : self.shortcut
  end 

  private 
      def has_shortcut
        return !shortcut.blank?
      end 

end # of class
