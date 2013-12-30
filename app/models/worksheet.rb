# == Schema Information
#
# Table name: worksheets
#
#  id         :integer         not null, primary key
#  student_id :integer
#  exam_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  marks      :float
#  graded     :boolean         default(FALSE)
#  honest     :integer
#  received   :boolean         default(FALSE)
#  signature  :string(50)
#  uid        :string(40)
#  quiz_id    :integer
#

class Worksheet < ActiveRecord::Base
  belongs_to :student
  belongs_to :exam  

  after_create :create_signature

  def self.of_student(id)
    where(:student_id => id)
  end

  def self.for_exam(id)
    where(:exam_id => id)
  end

  def received?(extent = :fully) # other options - :none, :partially
    # Returns true if scans have been received for some or all 
    # of the responses  

    return ( extent == :none ? false : true ) if self.received

    gr = GradedResponse.where(worksheet_id: self.id)
    n_total = gr.count 
    n_with_scan = gr.with_scan.count 
    self.update_attribute :received, true if (n_with_scan == n_total)

    ret = false 
    case extent
      when :none
        ret = (n_with_scan == 0)
      when :partially 
        ret = (n_with_scan > 0 && n_with_scan < n_total)
      when :fully 
        ret = n_with_scan == n_total 
    end
    return ret
  end

  def complete?
    return self.received? :fully
  end

  def publishable?
    # A student's answer sheete becomes publishable as soon as the 
    # last of the graded responses has been graded

    submitted = GradedResponse.where(worksheet_id: self.id).with_scan
    return false if submitted.count == 0
    return submitted.ungraded.count == 0
  end

  def honest?
    # Returns the confidence we have that the student truly earned 
    # the points he/she earned. Store only if honesty scores available for 
    # all responses

    unless self.honest.nil?
      case self.honest
        when 0 then return :red
        when 1, 2, 3 then return :orange 
        when 4 then return :green 
      end
    end

    g = GradedResponse.where(worksheet_id: self.id)
    scans = g.with_scan

    return :disabled if scans.count == 0

    posns = scans.graded.map(&:feedback).map{ |m| m & 15 }.uniq
    scores = Requirement.where(:honest => true, :posn => posns)
    
    return :nodata if scores.empty?
    lowest = scores.map(&:weight).sort.first

    if scans.ungraded.count == 0
      self.update_attribute :honest, lowest 
    end

    case lowest
      when 0 then return :red
      when 1,2,3 then return :orange
      else return :green
    end


=begin
    score = 0 
    posns.uniq.each do |m| 
      score += (Requirement.where(:honest => true, :posn => m).map(&:weight).first * posns.count(m))  
    end 

    unless n == 0
      score = ((score / ( 4 * n ).to_f) * 100).round(0) # max-weight = 4
      self.update_attribute(:honest, score) unless g.ungraded.count
    end
    return ( n ? score : "-" ) # for times when none of the responses have been graded
=end
  end 

  def graded?( extent = :fully ) # or :partially or :none
    return (extent != :none) if self.graded

    ret = false
    if self.exam.publishable
      ret = ( extent == :none ) ? false : true
      self.update_attribute :graded, true unless (extent == :none)
    else
      gr = GradedResponse.where(worksheet_id: self.id)
      case extent
        when :fully 
          ret = gr.count ? (gr.graded.count == gr.count) : false 
        when :partially 
          ret = gr.count ? (gr.graded.count && (gr.graded.count < gr.count)) : false
        when :none
          ret = (gr.graded.count == 0) 
      end
      self.update_attribute(:graded, true) if (ret && (extent == :fully))
    end
    return ret
  end 

  def marks?
    return self.marks unless self.marks.nil?

    g = GradedResponse.where(worksheet_id: self.id)
    marks = g.graded.map(&:marks?).select{ |m| !m.nil? }.inject(:+)
    self.update_attributes(marks: marks, graded: true) if g.ungraded.count == 0
    return marks.nil? ? 0 : marks.round(2)
  end

  def graded_thus_far?
    # Returns the total (of quiz) graded till now. This number will change as more 
    # and more of the student's exam is graded 
    return self.exam.quiz.total? if self.graded?

    g = GradedResponse.where(worksheet_id: self.id)
    thus_far = g.graded.map(&:subpart).map(&:marks).select{ |m| !m.nil? }.inject(:+)
    return thus_far.nil? ? 0 : thus_far # will always be an integer!
  end

  def graded_thus_far_as_str
    # Returns a string of the form "marks / graded_thus_far" - where marks are whats been earned till now
    absent = GradedResponse.of_student(self.student_id).in_exam(self.exam_id).with_scan.count == 0
    marks = absent ? -1 : self.marks?
    return (absent ? "no scans" : "#{marks} / #{self.graded_thus_far?}")
  end

  def signature?
    return self.signature.split(',') unless self.signature.blank?
    self.create_signature
  end

  def create_signature 
    if self.signature.nil?
      n = QSelection.where(quiz_id: self.exam.quiz_id).count
      sig = [*1..n].map{ rand(4) }
      self.update_attribute :signature, sig.join(',')
    end
    return sig 
  end

end # of class
