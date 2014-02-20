# == Schema Information
#
# Table name: transactions
#
#  id             :integer         not null, primary key
#  customer_id    :integer
#  account_id     :integer
#  quantity       :integer
#  rate_code_id   :integer
#  reference_id   :integer
#  reference_type :integer
#  memo           :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

 
#  reference_id - reference_type
#  -----------------------------
#  contract_id  - subscription Charge for Service/Platform/Parental-Access
#  course_id    - course       Course Purchase by student
#  payment_id   - cash         Cash transaction (of any kind) payment or refund
#  recepient_id - credit       Credit transaction (free credit, or transfer)

class Transaction < ActiveRecord::Base
  belongs_to :customer

  TYPE = {
    subscription: 0,
    course: 1,
    payment: 2,
    credit: 3,
    transfer: 4,
    refund: 5
  }
 
  validates_inclusion_of :reference_type, :in => TYPE.values 

  def self.by_account(id) 
    where(account_id: id) 
  end

  def self.by_customer(id)
    where(customer_id: id)
  end

  def self.for_course(id)
    where(reference_id: id, reference_type: "Course")
  end

  def self.for_contract(id)
    where(reference_id: id, reference_type: "Contract")
  end

  def self.for_credits(id)
    where(reference_id: id, reference_type: "Payment")
  end

  def self.new_subscription_charge!

  end

  def self.new_course_purchase!

  end

  def self.new_cash_payment!

  end

  def self.new_credit_purchase!

  end

  def self.new_credit_transfer!

  end

  def self.new_credit_refund!

  end

end

