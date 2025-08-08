class AdminAuditLog < ApplicationRecord
  belongs_to :admin, class_name: 'User'
  
  validates :action, presence: true, length: { minimum: 3, maximum: 100 }
  validates :details, presence: true
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_admin, ->(admin_id) { where(admin_id: admin_id) }
  scope :today, -> { where('created_at >= ?', Date.current.beginning_of_day) }
  scope :this_week, -> { where('created_at >= ?', Date.current.beginning_of_week) }
  scope :this_month, -> { where('created_at >= ?', Date.current.beginning_of_month) }
  
  def self.log_action(admin, action, details = {})
    create!(
      admin: admin,
      action: action,
      details: details.merge(
        timestamp: Time.current,
        ip_address: details[:ip_address],
        user_agent: details[:user_agent]
      )
    )
  end
  
  def action_summary
    case action
    when 'booking_created'
      "Created booking ##{details['booking_id']}"
    when 'booking_updated'
      "Updated booking ##{details['booking_id']}"
    when 'booking_cancelled'
      "Cancelled booking ##{details['booking_id']}"
    when 'payment_processed'
      "Processed payment ##{details['payment_id']}"
    when 'price_override_set'
      "Set price override for #{details['property_name']} on #{details['date']}"
    when 'blackout_date_set'
      "Set blackout date for #{details['property_name']} on #{details['date']}"
    when 'user_created'
      "Created user #{details['user_email']}"
    when 'user_updated'
      "Updated user #{details['user_email']}"
    else
      action.humanize
    end
  end
  
  def details_summary
    details.except('timestamp', 'ip_address', 'user_agent').map do |key, value|
      "#{key.humanize}: #{value}"
    end.join(', ')
  end
end
