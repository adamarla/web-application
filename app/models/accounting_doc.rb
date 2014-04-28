# == Schema Information
#
# Table name: accounting_docs
#
#  id          :integer         not null, primary key
#  doc_type    :integer
#  customer_id :integer
#  doc_date    :date
#  open        :boolean
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class AccountingDoc < ActiveRecord::Base
  belongs_to :customer

  has_many :transactions

  DOC_TYPE = {
    invoice: 0,
    credit_note: 1, 
    debit_note: 2
  }
  validates_inclusion_of :doc_type, :in => DOC_TYPE.values

  before_create :set_doc_date

  def self.open_ones
    where(open: true)
  end

  def self.closed_ones
    where(open: false)
  end

  def self.credit_note
    where(doc_type: DOC_TYPE[:credit_note])    
  end

  def self.invoice
    where(doc_type: DOC_TYPE[:invoice])    
  end

  def self.new_credit_note
    AccountingDoc.new doc_type: DOC_TYPE[:credit_note], doc_date: Date.today
  end

  def self.new_invoice
    AccountingDoc.new doc_type: DOC_TYPE[:invoice], doc_date: Date.today
  end

  def display
    if self.open
      "#{self.doc_date} to Present"
    else
      "#{self.doc_date} to #{self.updated_at.to_date}"
    end
  end

  def close
    if balance == 0
      self.update_attribute :open, false
    else
      return false
    end
  end

  def balance
    balance = 0
    self.transactions.each do |t|
      balance += t.quantity
    end
    return balance
  end

  private

    def set_doc_date
      self.doc_date = Date.today
    end

end

