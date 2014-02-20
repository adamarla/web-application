# == Schema Information
#
# Table name: customers
#
#  id             :integer         not null, primary key
#  account_id     :integer
#  credit_balance :integer
#  cash_balance   :integer
#  currency       :string(3)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

class Customer < ActiveRecord::Base
  belongs_to :account
  
  has_many :transactions

  def apply_payment(payment)
    case customer.account.loggable_type
      when "School":
        #TO DO: Get RateCode from Contract    
      when "Guardian":
        RateCode.for_course_credit(payment.currency) 
      when "Student":
        RateCode.for_course_credit(payment.currency) 
    end
    t = Transaction.new customer_id: id, account_id: account_id, 
                        quantity: payment.credits, rate_code_id: rc,  
                        reference_id: payment_id, 
                        reference_type: Transaction::TYPE[:payment], 
                        memo: "Logged on acct #{current_account.loggable}"
    if t.save
      self.update_attribute :credit_balance, (self.credit_balance += payment.credits)
    end
  end

end
