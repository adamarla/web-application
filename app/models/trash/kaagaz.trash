# == Schema Information
#
# Table name: kaagaz
#
#  id      :integer         not null, primary key
#  path    :string(40)
#  stab_id :integer
#

class Kaagaz < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :stab 
  has_many :remarks, dependent: :destroy 

  validates :path, presence: true
  validates :path, uniqueness: { scope: :stab_id }

  def annotate(tex, x,y) 
    cmnt = TexComment.where(text: tex).first 
    cmnt = cmnt.nil? ? TexComment.create(examiner_id: self.stab.examiner_id, text: tex) : cmnt 
    rmk = self.remarks.build(tex_comment_id: cmnt.id, x: x, y: y)
    return rmk.save
  end 

  def self.annotate(p) # p = params[:kgz] as in grade/stab
    all_good = true
    p.each do |id, cmnts|
      kgz = Kaagaz.find id.to_i
      cmnts.each do |index, cmnt|
        all_good &= kgz.annotate(cmnt[:tex], cmnt[:x].to_i, cmnt[:y].to_i)
        break unless all_good 
      end 
      break unless all_good 
    end 
    return all_good
  end 

end
