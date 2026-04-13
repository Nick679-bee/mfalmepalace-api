class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :property
  has_many :payments, dependent: :destroy
  
  validates :check_in, presence: true
  validates :check_out, presence: true
  validates :guests_count, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10 }
  validates :price_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: %w[KSH USD EUR] }
  validates :status, presence: true, inclusion: { in: %w[pending confirmed cancelled refunded] }
  validates :payment_status, presence: true, inclusion: { in: %w[pending paid failed refunded] }
  
  validate :check_out_after_check_in
  validate :property_available_for_dates
  validate :guests_count_within_limit
  validate :booking_not_in_past
  
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :pending, -> { where(status: 'pending') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :refunded, -> { where(status: 'refunded') }
  scope :paid, -> { where(payment_status: 'paid') }
  scope :pending_payment, -> { where(payment_status: 'pending') }
  scope :upcoming, -> { where('check_in >= ?', Date.current) }
  scope :past, -> { where('check_out < ?', Date.current) }
  scope :current, -> { where('check_in <= ? AND check_out >= ?', Date.current, Date.current) }
  
  before_validation :set_default_status, on: :create
  before_validation :calculate_price, on: :create
  # after_create :send_booking_confirmation_email  # Temporarily disabled
  # after_update :send_status_update_email, if: :saved_change_to_status?  # Temporarily disabled
  
  def nights
    return 0 unless check_in && check_out
    (check_out - check_in).to_i
  end
  
  def total_amount
    Money.new(price_cents, currency)
  end
  
  def can_be_cancelled?
    confirmed? && check_in > Date.current + 2.days
  end
  
  def confirmed?
    status == 'confirmed'
  end
  
  def pending?
    status == 'pending'
  end
  
  def cancelled?
    status == 'cancelled'
  end
  
  def refunded?
    status == 'refunded'
  end
  
  def paid?
    payment_status == 'paid'
  end
  
  def cancel!
    return false unless can_be_cancelled?
    
    update(status: 'cancelled')
    send_cancellation_email
  end
  
  def confirm!
    update(status: 'confirmed')
  end
  
  private
  
  def check_out_after_check_in
    return unless check_in && check_out
    
    if check_out <= check_in
      errors.add(:check_out, 'must be after check-in date')
    end
  end
  
  def property_available_for_dates
    return unless property && check_in && check_out
    
    unless property.available_for_dates?(check_in, check_out)
      errors.add(:base, 'Property is not available for the selected dates')
    end
  end
  
  def guests_count_within_limit
    return unless property && guests_count
    
    if guests_count > property.max_guests
      errors.add(:guests_count, "cannot exceed #{property.max_guests} guests")
    end
  end
  
  def booking_not_in_past
    return unless check_in
    
    if check_in < Date.current
      errors.add(:check_in, 'cannot be in the past')
    end
  end
  
  def set_default_status
    self.status ||= 'pending'
    self.payment_status ||= 'pending'
    self.currency ||= 'KSH'
  end
  
  def calculate_price
    return unless property && check_in && check_out
    
    calculated_price = property.calculate_price_for_dates(check_in, check_out)
    if calculated_price.nil?
      errors.add(:base, 'Property is not available for the selected dates (blackout)')
    else
      self.price_cents = calculated_price
    end
  end
  
  def send_booking_confirmation_email
    # TODO: Implement email sending with background job
    BookingMailer.confirmation(self).deliver_later
  end
  
  def send_status_update_email
    # TODO: Implement email sending with background job
    BookingMailer.status_update(self).deliver_later
  end
  
  def send_cancellation_email
    # TODO: Implement email sending with background job
    BookingMailer.cancellation(self).deliver_later
  end
end
