# == Schema Information
#
# Table name: doubts
#
#  id          :integer         not null, primary key
#  student_id  :integer
#  examiner_id :integer
#  scan        :string(30)
#  solution    :string(30)
#  tags        :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  in_db       :boolean         default(FALSE)
#

class Doubt < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :student 
  belongs_to :examiner 

  validates :scan, presence: true

  after_create :assign_to_examiner
  after_update :send_mail, if: :solution_changed?

  def self.resolved 
    where('solution IS NOT ?', nil)
  end 

  def self.unresolved 
    where(solution: nil)
  end 

  def self.by_student(id)
    where(student_id: id)
  end

  def self.assigned_to(id)
    where(examiner_id: id)
  end 

  private 
      
      def assign_to_examiner
        # for now, assign doubts only to internal examiners
        eid = Examiner.internal.available.sample(1).map(&:id).first 
        update_attribute :examiner_id, eid
        # send an acknowledgement mail to the student saying that a written solution 
        # would be made available within 24 hours.
      end 

      def send_mail
        return true
      end

end
