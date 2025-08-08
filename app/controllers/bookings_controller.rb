class BookingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]
  before_action :require_admin!, only: [:index]
  def index
    render json: Booking.order(created_at: :desc).map { |b| serialize_booking(b) }
  end

  def destroy
    booking = Booking.find(params[:id])
    authorize_booking!(booking)
    booking.destroy!
    head :no_content
  end

  def create
    permitted = params.require(:booking).permit(:property_id, :check_in, :check_out, :guests_count, :special_requests)
    property = Property.find(permitted[:property_id])

    booking = current_user ? current_user.bookings.new : Booking.new(user: guest_user)
    booking.assign_attributes(
      property: property,
      check_in: Date.parse(permitted[:check_in]),
      check_out: Date.parse(permitted[:check_out]),
      guests_count: permitted[:guests_count],
      special_requests: permitted[:special_requests]
    )
    booking.save!

    render json: serialize_booking(booking), status: :created
  end

  def show
    booking = Booking.find(params[:id])
    authorize_booking!(booking)
    render json: serialize_booking(booking)
  end

  private

  def authorize_booking!(booking)
    return if current_user&.admin? || (current_user && booking.user_id == current_user.id)
    render json: { error: 'Forbidden' }, status: :forbidden
  end

  def guest_user
    User.guests.find_or_create_by!(email: "guest+#{SecureRandom.hex(4)}@example.com") do |u|
      u.name = 'Guest User'
      u.phone = '+254-700-000-000'
      u.password = SecureRandom.base64(12)
    end
  end

  def serialize_booking(b)
    {
      id: b.id,
      property_id: b.property_id,
      user_id: b.user_id,
      check_in: b.check_in,
      check_out: b.check_out,
      nights: b.nights,
      guests_count: b.guests_count,
      currency: b.currency,
      price_cents: b.price_cents,
      status: b.status,
      payment_status: b.payment_status,
      special_requests: b.special_requests
    }
  end
end

