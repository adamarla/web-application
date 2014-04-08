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
#  reference_type    :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

 
class Transaction < ActiveRecord::Base
  belongs_to :accounting_doc

  has_one :rate_code

  TYPE = {           # reference_id => 
    subscription: 0, #   contract_id(school/uni/parent)
    course: 1,       #   course_id
    payment: 2,      #   payment_id (payment or refund)
    transfer: 3,     #   customer_id (sender/recepient)
    adjustment: 4    #   accounting_doc_id (other one)
  }
  validates_inclusion_of :reference_type, :in => TYPE.values 
 

  def self.by(id) 
    where(account_id: id) 
  end

  def self.for_course(id)
    where(reference_type: TYPE[:course], reference_id: id) 
  end

  def self.new_payment(credits, ref_id, code, account)
    self.make_new credits, ref_id, code, account, TYPE[:payment]
  end

  def self.new_adjustment(credits, ref_id, code, account)
    self.make_new credits, ref_id, code, account, TYPE[:adjustment]
  end

  def self.new_transfer(credits, ref_id, code, account)
    self.make_new credits, ref_id, code, account, TYPE[:transfer]
  end
  
  def self.new_course(credits, ref_id, code, account)
    self.make_new (credits*-1), ref_id, code, account, TYPE[:course]
  end

  def display
    case self.reference_type
    when TYPE[:payment]
      signature = " #{Payment.find(self.reference_id).name}"
    when TYPE[:course]
      signature = " #{Course.find(self.reference_id).name}"
    when TYPE[:adjustment]
      signature = " #{AccountingDoc.find(self.reference_id).customer.account.loggable.name}"
    when TYPE[:transfer]
      signature = " #{Customer.find(self.reference_id).students.first.name}"
    end
    "#{self.created_at.to_s[0..10]} #{TYPE.keys[self.reference_type].to_s} #{signature}"
  end

  def letter_code
    case self.reference_type
    when TYPE[:payment]
      "P"
    when TYPE[:course]
      "C"
    when TYPE[:adjustment]
      "A"
    when TYPE[:transfer]
      "T"
    end
  end

  private

    def self.make_new credits, ref_id, code, account, type
      Transaction.new account_id: account,
                      quantity: credits,
                      rate_code_id: code,
                      reference_id: ref_id,
                      reference_type: type
    end

end

