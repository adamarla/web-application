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
#  n_used      :integer         default(0)
#

class TexComment < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :examiner
  has_many :remarks

  validates :text, uniqueness: true

  def trivial?
    return self.trivial unless self.trivial.nil?
    c = crux # private method call !
    txt = c.select{ |j| j =~ /^text/ }
    math = (c - txt).select{ |m| !(m =~ /surd|times|\?/) } # ignore standalone $\surd$, $\times$ and $?$ as math
    n_words = txt.blank? ? 0 : txt.map{ |m| m.split.count }.inject(:+) # number of english words
    trivial =  n_words < 7 && math.count < 1
    self.update_attribute :trivial, trivial
    return trivial
  end

  def up_used_count 
    self.update_attribute :n_used, (self.n_used + 1)
  end 



  # Doodles and Tryouts only. Will deprecate in time 
  def self.record(comments, e_id, a_id, d_id = nil)
    # comments -> an array of TeX comments with x- and y- coordinates 
    # eid -> examiner id 
 
    # TexComment = only the TeX  
    # Remark = TeX + positional information + tryout_id  
    # A Doodle is a collection of remarks for a question tryout by a non-live examiner 
    # - perhaps as part of the training / vetting process 

    q = d_id.nil? ? Tryout.find(a_id).subpart.question : nil 

    # Each chunk is of the form --> [x, y, TeX]
    for chunk in comments.each_slice(3).to_a 
      break if chunk.length != 3 # the tex w/ x- and y- coordinates
      written = chunk[2].squish
      tex = TexComment.where(text: written).first 
      tex = tex.nil? ? TexComment.create(text: written, examiner_id: e_id) : tex
      tex.remarks.create(x: chunk[0], y: chunk[1], tryout_id: a_id, doodle_id: d_id)
    end 
  end 

  private
      def crux 
        # Returns the array of non-trivial tokens in a comment 
        # Trivial tokens include: empty \text{ }, \*arrow and empty strings
        a = self.text.split("\\")
        return a.select{ |j| !j.blank? && !(j =~ /arrow/) && !(j =~ /^text{ }/) } 
      end

end
