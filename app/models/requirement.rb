# == Schema Information
#
# Table name: requirements
#
#  id         :integer         not null, primary key
#  text       :string(100)
#  bottomline :string(20)
#  honest     :boolean         default(FALSE)
#  cogent     :boolean         default(FALSE)
#  complete   :boolean         default(FALSE)
#  other      :boolean         default(FALSE)
#  weight     :integer         default(-1)
#  posn       :integer
#

class Requirement < ActiveRecord::Base
  validates :bottomline, :presence => true
  validates :weight, :inclusion => { :in => [*-1..4] }

  before_save :ensure_unique_type
  after_create :assign_position

  def self.honest 
    Requirement.where(:honest => true).order(:posn)
  end

  def self.cogent 
    Requirement.where(:cogent => true).order(:posn)
  end

  def self.complete 
    Requirement.where(:complete => true).order(:posn)
  end

  def self.other
    Requirement.where(:other => true).order(:posn)
  end

  def self.mangle_into_feedback( ids )
    mangled = 0 
    n_other = 0

    ids.each do |m|
      type, posn = Requirement.type_and_posn? m
      shift = 0
      # Each requirement can have 15 scales => posn = [0,14]. That looks plenty enough 
      # But if you find yourself adding a lot of new scales, then buttress the code here
      case type 
        when :honest 
          shift = 0     
        when :cogent 
          shift = 4
        when :complete
          shift = 8
        when :other
          shift = n_other < 4 ? 12 + (n_other << 2) : -1 # => atmost *5* other requirements
          n_other += 1
      end # of case  
      break if shift < 0 
      mangled |= (posn << shift)
    end # of each 
    return mangled
  end

  def self.unmangle_feedback(n)
    # Take the stored integer and return the list of Requirement IDs
    # Returns : [a,b,c,d,e,f ..], where its understood that a => honest, b => cogent, c => complete, d .. => other
    mask = 15
    rel = []

    [0,4,8,12,16,20,24,28].each do |shift|
      m = ( n & (mask << shift)) >> shift 
      break if m == 0
      rel.push (m-1)
    end

    # rel = array of relative indices

    actual = [] 
    rel.each_with_index do |i,j|
      case j
        when 0
          r = Requirement.where(:honest => true)
        when 1
          r = Requirement.where(:cogent => true)
        when 2
          r = Requirement.where(:complete => true)
        else
          r = Requirement.where(:other => true)
      end # of case
      r = r.where(:posn => i).first.id
      actual.push r
    end # of each
    return actual
  end

  def self.marks_if?(feedback)
    # Returns the fraction of marks to given a certain feedback

    feedback = feedback.class == Fixnum ? self.unmangle_feedback(feedback) : feedback
    feedback = Requirement.where(:id => feedback)

    honest = feedback.where(:honest => true).select(:weight).first.weight 
    if honest > 0
      cogent = feedback.where(:cogent => true).select(:weight).first.weight 
      complete = feedback.where(:complete => true).select(:weight).first.weight 
      other = feedback.where(:other => true, :weight => 0).count
      other = (other > 2) ? 2 : other 
      fraction = ((cogent + complete) / 8.0) - (0.05 * other)
    else
      fraction = 0 # plagiarized => automatic 0 !!
    end 
    return (fraction > 0 ? fraction : 0)
  end

  def type?
    type = obj.other ? :other : (obj.honest ? :honest : (obj.cogent ? :cogent : :complete))
    return type
  end

  private 
    def ensure_unique_type
      return [self.honest, self.cogent, self.complete, self.other].count(true) == 1
    end 

    def assign_position
      type = self.type?
      last = Requirement.where(type => true).map(&:posn).sort.last
      self.update_attribute :posn, (last + 1)
    end

    def self.type_and_posn?(obj)
      obj = obj.class == Fixnum ? Requirement.find(obj) : obj
      return [obj.type?, obj.posn]
    end

end
