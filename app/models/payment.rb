class Payment < ApplicationRecord
  belongs_to :booking
  
  validates :provider, presence: true, inclusion: { in: %w[stripe paypal paystack] }
  validates :provider_payment_id, presence: true, uniqueness: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending succeeded failed cancelled refunded] }
  
  scope :succeeded, -> { where(status: 'succeeded') }
  scope :pending, -> { where(status: 'pending') }
  scope :failed, -> { where(status: 'failed') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :refunded, -> { where(status: 'refunded') }
  
  before_create :set_default_status
  after_create :update_booking_payment_status
  after_update :update_booking_payment_status, if: :saved_change_to_status?
  
  def amount
    Money.new(amount_cents, booking.currency)
  end
  
  def succeeded?
    status == 'succeeded'
  end
  
  def pending?
    status == 'pending'
  end
  
  def failed?
    status == 'failed'
  end
  
  def cancelled?
    status == 'cancelled'
  end
  
  def refunded?
    status == 'refunded'
  end
  
  def process_stripe_payment(payment_intent_id)
    return false unless provider == 'stripe'
    
    begin
      payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
      
      case payment_intent.status
      when 'succeeded'
        update(status: 'succeeded', metadata: payment_intent.to_h)
        true
      when 'requires_payment_method'
        update(status: 'failed', metadata: payment_intent.to_h)
        false
      when 'canceled'
        update(status: 'cancelled', metadata: payment_intent.to_h)
        false
      else
        update(status: 'pending', metadata: payment_intent.to_h)
        false
      end
    rescue Stripe::StripeError => e
      update(status: 'failed', metadata: { error: e.message })
      false
    end
  end
  
  def refund!
    return false unless succeeded?
    
    case provider
    when 'stripe'
      refund_stripe_payment
    when 'paypal'
      refund_paypal_payment
    when 'paystack'
      refund_paystack_payment
    else
      false
    end
  end
  
  private
  
  def set_default_status
    self.status ||= 'pending'
  end
  
  def update_booking_payment_status
    case status
    when 'succeeded'
      booking.update(payment_status: 'paid')
    when 'failed', 'cancelled'
      booking.update(payment_status: 'failed')
    when 'refunded'
      booking.update(payment_status: 'refunded')
    end
  end
  
  def refund_stripe_payment
    return false unless metadata&.dig('id')
    
    begin
      refund = Stripe::Refund.create(
        payment_intent: metadata['id'],
        reason: 'requested_by_customer'
      )
      
      update(status: 'refunded', metadata: metadata.merge(refund: refund.to_h))
      true
    rescue Stripe::StripeError => e
      update(metadata: metadata.merge(refund_error: e.message))
      false
    end
  end
  
  def refund_paypal_payment
    # TODO: Implement PayPal refund
    false
  end
  
  def refund_paystack_payment
    # TODO: Implement Paystack refund
    false
  end
end
