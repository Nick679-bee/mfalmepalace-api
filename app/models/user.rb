class User < ApplicationRecord
  has_secure_password
  
  has_many :bookings, dependent: :destroy
  has_many :admin_audit_logs, class_name: 'AdminAuditLog', foreign_key: 'admin_id', dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, format: { with: /\A\+?[\d\s\-\(\)]+\z/ }
  validates :role, presence: true, inclusion: { in: %w[guest admin] }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  
  before_validation :set_default_role, on: :create
  
  scope :guests, -> { where(role: 'guest') }
  scope :admins, -> { where(role: 'admin') }
  
  def admin?
    role == 'admin'
  end
  
  def guest?
    role == 'guest'
  end
  
  def generate_jwt_token
    JWT.encode(
      { user_id: id, email: email, role: role, exp: 24.hours.from_now.to_i },
      Rails.application.credentials.secret_key_base,
      'HS256'
    )
  end
  
  private
  
  def set_default_role
    self.role ||= 'guest'
  end
end
