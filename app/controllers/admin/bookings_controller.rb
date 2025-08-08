module Admin
  class BookingsController < ApplicationController
    before_action :require_admin!

    def index
      scope = Booking.includes(:user, :property).order(created_at: :desc)
      scope = scope.where(status: params[:status]) if params[:status].present?
      if params[:from].present? && params[:to].present?
        from = Date.parse(params[:from])
        to = Date.parse(params[:to])
        scope = scope.where('check_in >= ? AND check_out <= ?', from, to)
      end
      render json: scope.map { |b| serialize_admin_booking(b) }
    end

    def show
      b = Booking.find(params[:id])
      render json: serialize_admin_booking(b)
    end

    def create
      permitted = params.require(:booking).permit(:user_id, :property_id, :check_in, :check_out, :guests_count, :price_cents, :currency, :status, :payment_status, :special_requests)
      b = Booking.create!(permitted)
      AdminAuditLog.log_action(current_user, 'booking_created', { booking_id: b.id })
      render json: serialize_admin_booking(b), status: :created
    end

    def update
      b = Booking.find(params[:id])
      permitted = params.require(:booking).permit(:check_in, :check_out, :guests_count, :price_cents, :currency, :status, :payment_status, :special_requests)
      b.update!(permitted)
      AdminAuditLog.log_action(current_user, 'booking_updated', { booking_id: b.id })
      render json: serialize_admin_booking(b)
    end

    def destroy
      b = Booking.find(params[:id])
      b.update!(status: 'cancelled')
      AdminAuditLog.log_action(current_user, 'booking_cancelled', { booking_id: b.id })
      head :no_content
    end

    private

    def serialize_admin_booking(b)
      {
        id: b.id,
        property: { id: b.property.id, name: b.property.name },
        user: { id: b.user.id, name: b.user.name, email: b.user.email },
        check_in: b.check_in,
        check_out: b.check_out,
        nights: b.nights,
        guests_count: b.guests_count,
        currency: b.currency,
        price_cents: b.price_cents,
        status: b.status,
        payment_status: b.payment_status,
        created_at: b.created_at
      }
    end
  end
end

