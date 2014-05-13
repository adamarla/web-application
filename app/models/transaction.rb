# == Schema Information
#
# Table name: transactions
#
#  id                :integer         not null, primary key
#  accounting_doc_id :integer
#  account_id        :integer
#  quantity          :integer
#  rate_code_id      :integer
#  reference_id      :integer
#  memo              :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

 
class Transaction < ActiveRecord::Base
  belongs_to :accounting_doc

  has_one :rate_code
=begin
  TYPE = {           # reference_id => 
    subscription: 0, #   contract_id(school/uni/parent)
    course: 1,       #   course_id
    payment: 2,      #   payment_id (payment or refund)
    transfer: 3,     #   customer_id (sender/recepient)
    adjustment: 4    #   accounting_doc_id (other one)
  }
  validates_inclusion_of :reference_type, :in => TYPE.values 
=end

  def self.by(account) 
    where(account_id: account.id) 
  end

  def self.for_course(course)
    where(reference_id: course.id, memo: course.name)
  end

  def letter_code
    CostCode.find(RateCode.find(self.rate_code_id).cost_code_id).description[0]
  end

  def display
    "#{self.created_at.to_s[0..10]} #{memo}"    
  end

end

