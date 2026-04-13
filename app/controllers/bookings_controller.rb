class BookingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create, :index]
  # before_action :require_admin!, only: [:index]  # Temporarily disabled for testing
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
    permitted = params.require(:booking).permit(
      :property_id, :check_in, :check_out, :guests_count, :special_requests,
      :guest_name, :guest_email, :guest_phone, :payment_method
    )
    property = Property.find(permitted[:property_id])
    
    check_in = Date.parse(permitted[:check_in])
    check_out = Date.parse(permitted[:check_out])
    nights = [(check_out - check_in).to_i, 0].max
    
    payment_method = permitted[:payment_method].to_s
    is_mpesa = payment_method == "mpesa"

    booking = Booking.new(user: booking_user(permitted))
    booking.assign_attributes(
      property: property,
      check_in: check_in,
      check_out: check_out,
      guests_count: permitted[:guests_count] || 1,
      price_cents: property.base_price_cents * nights,
      currency: "KSH",
      status: is_mpesa ? "pending" : "confirmed",
      payment_status: is_mpesa ? "pending" : "paid",
      special_requests: permitted[:special_requests]
    )
    booking.save!

    render json: serialize_booking(booking), status: :created
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Property not found" }, status: :not_found
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
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

  def booking_user(permitted)
    return current_user if current_user

    guest_email = permitted[:guest_email].presence
    guest_name = permitted[:guest_name].presence || "Guest User"
    guest_phone = permitted[:guest_phone].presence || "+254-700-000-000"

    return guest_user unless guest_email

    user = User.find_or_initialize_by(email: guest_email.downcase)
    user.name = guest_name if user.name.blank? || permitted[:guest_name].present?
    user.phone = guest_phone if user.phone.blank? || permitted[:guest_phone].present?
    user.role = "guest"
    user.password = SecureRandom.base64(12) if user.new_record?
    user.save!
    user
  end

  def serialize_booking(b)
    nights = [(b.check_out - b.check_in).to_i, 0].max
    {
      id: b.id,
      property_id: b.property_id,
      user_id: b.user_id,
      guest_name: b.user&.name,
      guest_email: b.user&.email,
      guest_phone: b.user&.phone,
      check_in: b.check_in,
      check_out: b.check_out,
      nights: nights,
      guests_count: b.guests_count,
      currency: b.currency,
      price_cents: b.price_cents,
      status: b.status,
      payment_status: b.payment_status,
      special_requests: b.special_requests
    }
  end
end

