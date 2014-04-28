#!/bin/env ruby
# encoding: utf-8
#
# http://stackoverflow.com/questions/1739836/invalid-multibyte-char-us-ascii-with-rails-and-ruby-1-9
#
# == Schema Information
#
# Table name: payments
#
#  id               :integer         not null, primary key
#  invoice_id       :integer
#  ip_address       :string(16)
#  name             :string(60)
#  source           :string(30)
#  cash_value       :integer
#  currency         :string(3)
#  credits          :integer
#  success          :boolean
#  response_message :string(255)
#  response_params  :text
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

class Payment < ActiveRecord::Base
  belongs_to :invoice

  serialize :response_params

  attr_accessor :email, :card_number, :card_verification, :expiration, :address1, :city, :state, :country, :zip

  validates :email, :presence => true 
  validates :name, :presence => true 
  validates :card_number, :presence => true, numericality: true
  validates :card_verification, :presence => true, numericality: true
  validates :address1, :presence => true 
  validates :city, :presence => true 
  validates :state, :presence => true 
  validates :zip, :presence => true 
  validates :country, :presence => true 

  validate :validate_payment, on: :create

  def execute(refund = false)
    unless refund
      response = STANDARD_GATEWAY.purchase price_in_cents, credit_card, payment_options
    else 
      response = STANDARD_GATEWAY.transfer price_in_cents, self.email, :subject => "refund request by #{self.name}", :note => "Refund worth #{self.cash_value} has been processed as per your request"
    end
    self.update_attributes success: response.success?,
                           response_message: response.message,
                           response_params: response.params.to_s
  end

  def price_in_cents
    (self.cash_value * 100).round
  end

  def validate_payment
    if self.card_number.length > 0
      unless credit_card.valid?
        credit_card.errors.full_messages.each do |msg|
          errors.add :base, "#{msg}"
        end
      end
    else
      true
    end
  end

  def credit_card
    fn, ln = name.split(' ')
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :brand              => source,
      :number             => card_number,
      :verification_value => card_verification, 
      :month              => expiration[:month],
      :year               => expiration[:year],
      :first_name         => fn,
      :last_name          => ln
    )
  end

  def display_value
    symbols = {
      "INR" => "₹",
      "USD" => "$"
    }
    "#{symbols[self.currency]}#{self.cash_value}"
  end

  private

    def payment_options
      {
        ip: ip_address,
        billing_address: {
          name: name,
          address1: address1,
          city: city,
          state: state,
          country: country,
          zip: zip
        }
      }
    end

end
