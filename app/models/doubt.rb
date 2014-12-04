# == Schema Information
#
# Table name: doubts
#
#  id          :integer         not null, primary key
#  student_id  :integer
#  examiner_id :integer
#  scan        :string(30)
#  solution    :string(30)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  in_db       :boolean         default(FALSE)
#  refunded    :boolean         default(FALSE)
#  price       :integer
#

class Doubt < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :student 
  belongs_to :examiner 

  after_create :assign_to_examiner
  after_update :send_mail, if: :solution_changed?

  acts_as_taggable_on :tags

  def self.solved 
    where('solution IS NOT ?', nil)
  end 

  def self.unsolved 
    where(solution: nil)
  end 

  def self.pending 
    where(solution: nil, refunded: false)
  end 

  def self.by_student(id)
    where(student_id: id)
  end

  def self.assigned_to(id)
    where(examiner_id: id)
  end 

  def self.refunded 
    where(refunded: true)
  end 

  def self.price? 
    return 4 
    # going forward, this method could return a different price 
    # for different users depending on where they are from and when 
    # they are asking for their doubts to be cleared ( closed to exams => higher price )
  end 

  def name? 
    # should factor in any tags set on it.
    return self.created_at.strftime("%b %d, %Y")
  end 

  def refund
    return false if self.refunded # do NOT double refund !! 
    s = self.student 
    refund = self.price * -1 # amounts < 0 => refunds
    s.charge refund 
    self.update_attribute :refunded, true
    # send mail to student saying that the question couldn't be
    # solved by us and hence gredits have been refunded.
  end 

  def tagged? 
    !self.tag_list.empty?
  end 

  def charge
    self.student.charge Doubt.price? 
  end

  private 
      
      def assign_to_examiner
        # for now, assign doubts only to internal examiners
        eid = Examiner.internal.available.sample(1).map(&:id).first 
        update_attribute :examiner_id, eid
        # store the price charged for clearing this doubt. 
        # Do NOT assume its a constant price! Price = f( student, time, workload ). 
        # This is also the price one should refund.
        price = Doubt.price? 
        update_attribute :price, price 
        # send an acknowledgement mail to the student saying that a written solution 
        # would be made available within 24 hours.
      end 

      def send_mail
        return true
      end

end
