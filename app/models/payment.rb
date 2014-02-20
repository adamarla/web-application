# == Schema Information
#
# Table name: payments
#
#  id               :integer         not null, primary key
#  transaction_id   :integer
#  ip_address       :string(16)
#  first_name       :string(30)
#  last_name        :string(30)
#  payment_type     :string(30)
#  cash_value       :integer
#  currency         :string(255)
#  credits          :integer
#  success          :boolean
#  response_message :string(255)
#  response_params  :string(255)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

class Payment < ActiveRecord::Base
  belongs_to :transaction

  serialize :response_params

  attr_accessor :email, :card_number, :card_verification, :expiration, :address1, :city, :state, :country, :zip
  
  validate :validate_card, on: :create

  def execute
    return STANDARD_GATEWAY.purchase price_in_cents, credit_card, payment_options
  end

  def price_in_cents
    (self.amount * 100).round
  end

  def validate_card
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |msg|
        errors.add :base, msg
      end
    end
  end

  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :brand              => payment_type,
      :number             => card_number,
      :verification_value => card_verification, 
      :month              => expiration[:month],
      :year               => expiration[:year],
      :first_name         => first_name,
      :last_name          => last_name 
    )
  end

  private

    def payment_options
      {
        ip: ip_address,
        billing_address: {
          name: "#{first_name} #{last_name}",
          address1: address1,
          city: city,
          state: state,
          country: country,
          zip: zip
        }
      }
    end

end
