module Admin
  class PricesController < ApplicationController
    before_action :require_admin!

    def create
      permitted = params.require(:price).permit(:property_id, :date, :price_cents, :is_blackout)
      po = PriceOverride.create!(permitted)
      AdminAuditLog.log_action(current_user, (po.is_blackout ? 'blackout_date_set' : 'price_override_set'), { property_name: po.property.name, date: po.date })
      render json: serialize(po), status: :created
    end

    def index
      scope = PriceOverride.includes(:property).order(date: :asc)
      scope = scope.where(property_id: params[:property_id]) if params[:property_id].present?
      render json: scope.map { |po| serialize(po) }
    end

    private

    def serialize(po)
      {
        id: po.id,
        property: { id: po.property.id, name: po.property.name },
        date: po.date,
        price_cents: po.price_cents,
        is_blackout: po.is_blackout
      }
    end
  end
end

