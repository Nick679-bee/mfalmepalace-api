class PriceOverride < ApplicationRecord
  belongs_to :property
  
  validates :date, presence: true
  validates :price_cents, numericality: { greater_than: 0 }, allow_nil: true
  validates :is_blackout, inclusion: { in: [true, false] }
  
  validate :date_not_in_past
  validate :price_or_blackout
  validate :unique_date_per_property
  
  scope :blackout_dates, -> { where(is_blackout: true) }
  scope :price_overrides, -> { where(is_blackout: false) }
  scope :future_dates, -> { where('date >= ?', Date.current) }
  scope :past_dates, -> { where('date < ?', Date.current) }
  
  before_validation :set_default_is_blackout
  
  def price
    return nil if price_cents.nil?
    Money.new(price_cents, 'KSH')
  end
  
  def blackout?
    is_blackout
  end
  
  def price_override?
    !is_blackout
  end
  
  def effective_price_cents
    return nil if blackout?
    price_cents || property.base_price_cents
  end
  
  private
  
  def date_not_in_past
    return unless date
    
    if date < Date.current
      errors.add(:date, 'cannot be in the past')
    end
  end
  
  def price_or_blackout
    if price_cents.nil? && !is_blackout
      errors.add(:base, 'Must specify either a price or mark as blackout')
    end
  end
  
  def unique_date_per_property
    return unless property && date
    
    existing_override = property.price_overrides.where(date: date)
    existing_override = existing_override.where.not(id: id) if persisted?
    
    if existing_override.exists?
      errors.add(:date, 'already has a price override for this property')
    end
  end
  
  def set_default_is_blackout
    self.is_blackout = false if is_blackout.nil?
  end
end
