class Property < ApplicationRecord
  has_many :bookings, dependent: :destroy
  has_many :price_overrides, dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 3, maximum: 200 }
  validates :property_type, presence: true, inclusion: { in: %w[one_bed two_bed] }
  validates :description, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :max_guests, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10 }
  validates :distance_to_airport_minutes, presence: true, numericality: { greater_than: 0 }
  validates :amenities, presence: true
  validates :photos, presence: true
  
  scope :one_bedroom, -> { where(property_type: 'one_bed') }
  scope :two_bedroom, -> { where(property_type: 'two_bed') }
  scope :pet_friendly, -> { where(pet_friendly: true) }
  scope :eco_friendly, -> { where(eco_friendly: true) }
  
  def available_for_dates?(check_in, check_out)
    return false if check_in >= check_out
    
    overlapping_bookings = bookings.confirmed.where(
      '(check_in < ? AND check_out > ?) OR (check_in < ? AND check_out > ?) OR (check_in >= ? AND check_out <= ?)',
      check_out, check_in, check_out, check_in, check_in, check_out
    )
    
    overlapping_bookings.empty?
  end
  
  def base_price_cents
    case property_type
    when 'one_bed'
      6500_00 # 6500 KSH in cents
    when 'two_bed'
      9500_00 # 9500 KSH in cents
    else
      0
    end
  end
  
  def calculate_price_for_dates(check_in, check_out)
    nights = (check_out - check_in).to_i
    return 0 if nights <= 0
    
    total_price = 0
    current_date = check_in
    
    nights.times do
      override = price_overrides.find_by(date: current_date)
      if override&.is_blackout?
        return nil # Blackout date
      elsif override&.price_cents
        total_price += override.price_cents
      else
        total_price += base_price_cents
      end
      current_date += 1.day
    end
    
    total_price
  end
  
  def amenities_list
    amenities.is_a?(Array) ? amenities : []
  end
  
  def photos_list
    photos.is_a?(Array) ? photos : []
  end
end
