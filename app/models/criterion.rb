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

  has_many :checklists, dependent: :destroy

  before_save :no_orange, if: :red_flag_changed?
  before_save :no_red, if: :orange_flag_changed?
  before_save :standard, if: :shortcut_changed?
  before_save :no_shortcut, if: :standard_changed?

  def self.standard
    where(standard: true)
  end 

  def reward? 
    return (100 - self.penalty)
  end 

  def penalty?
    return self.penalty
  end 

  def perception? 
    return (self.red_flag ? :red : (self.orange_flag ? :orange : :green))
  end 

  def self.available_shortcuts
    all = [*'0'..'9'] + [*'A'..'Z'] 
    reserved = ['H','R','W','U','F','S','L']
    used = Criterion.where('shortcut IS NOT ?', nil).map(&:shortcut)
    return (all - reserved - used)
  end 


  private 

      def no_red
        return true unless orange_flag # no problem if orange_flag is being set to false
        assign_attributes red_flag: false
      end 

      def no_orange
        return true unless red_flag # no problem if red_flag is being set to false 
        assign_attributes orange_flag: false
      end 

      def no_shortcut
        return true if standard
        assign_attributes shortcut: nil
      end 

end # of class
