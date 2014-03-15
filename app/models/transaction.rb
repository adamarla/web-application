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

  TYPE = {           # reference_id => 
    subscription: 1, #   contract_id(school/uni/parent)
    course: 2,       #   course_id
    payment: 3,      #   payment_id (payment or refund)
    transfer: 4,     #   customer_id (sender/recepient)
    adjustment: 5    #   accounting_doc_id (other one)
  }
  validates_inclusion_of :reference_type, :in => TYPE.values 
 

  def self.by_account(id) 
    where(account_id: id) 
  end

  def self.new_payment(payment, code, account)
    Transaction.new account_id: account.id,
                    quantity: payment.credits,
                    rate_code_id: code.id,
                    reference_id: payment.id,
                    reference_type: TYPE[:payment]
  end

  def self.new_adjustment(adjustment, code, account)
    Transaction.new account_id: account.id,
                    quantity: adjustment,
                    rate_code_id: code.id,
                    reference_type: TYPE[:adjustment]
  end

  def self.new_course_buy(student, course, code, account)
    Transaction.new account_id: account.id,
                    quantity: -1 * course.price,
                    rate_code_id: code.id,
                    reference_id: course.id,
                    reference_type: TYPE[:course]
  end

end

