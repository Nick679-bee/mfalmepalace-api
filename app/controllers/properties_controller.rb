class PropertiesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    props = Property.all.order(:name)
    render json: props.map { |p| serialize_property_summary(p) }
  end

  def show
    property = Property.find(params[:id])
    render json: serialize_property_detail(property)
  end

  private

  def serialize_property_summary(p)
    {
      id: p.id,
      name: p.name,
      type: p.property_type,
      max_guests: p.max_guests,
      pet_friendly: p.pet_friendly,
      eco_friendly: p.eco_friendly,
      photos: p.photos_list.take(3),
      nightly_rate_cents: p.base_price_cents,
      currency: "KES"
    }
  end

  def serialize_property_detail(p)
    today = Date.current
    next_30 = (today..(today + 30.days))
    blackout = p.price_overrides.blackout_dates.where(date: next_30).pluck(:date)

    {
      id: p.id,
      name: p.name,
      description: p.description,
      type: p.property_type,
      max_guests: p.max_guests,
      distance_to_airport_minutes: p.distance_to_airport_minutes,
      amenities: p.amenities_list,
      photos: p.photos_list,
      pet_friendly: p.pet_friendly,
      eco_friendly: p.eco_friendly,
      nightly_rate_cents: p.base_price_cents,
      currency: "KES",
      availability: {
        blackout_dates: blackout
      }
    }
  end
end

