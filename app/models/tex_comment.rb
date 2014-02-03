# == Schema Information
#
# Table name: tex_comments
#
#  id          :integer         not null, primary key
#  text        :text
#  examiner_id :integer
#  trivial     :boolean
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class TexComment < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :examiner
  has_many :remarks

  validates :text, uniqueness: true

  def trivial?
    return self.trivial unless self.trivial.nil?
    c = crux
    txt = c.select{ |j| j =~ /^text/ }
    math = (c - txt).select{ |m| !(m =~ /surd|times|\?/) } # ignore standalone $\surd$, $\times$ and $?$ as math
    n_words = txt.blank? ? 0 : txt.map{ |m| m.split.count }.inject(:+) # number of english words
    trivial =  n_words < 7 && math.count < 1
    self.update_attribute :trivial, trivial
    return trivial
  end

  private
      def crux 
        # Returns the array of non-trivial tokens in a comment 
        # Trivial tokens include: empty \text{ }, \*arrow and empty strings
        a = self.text.split("\\")
        return a.select{ |j| !j.blank? && !(j =~ /arrow/) && !(j =~ /^text{ }/) } 
      end

end
