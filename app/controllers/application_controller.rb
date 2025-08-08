class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  private

  def authenticate_user!
    @current_user = authenticate_with_http_token do |token, _options|
      begin
        payload, = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
        User.find_by(id: payload['user_id'])
      rescue JWT::DecodeError
        nil
      end
    end
    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def require_admin!
    render json: { error: 'Admin access required' }, status: :forbidden unless current_user&.admin?
  end

  def render_not_found
    render json: { error: 'Not Found' }, status: :not_found
  end

  def render_unprocessable(exception)
    errors = exception.respond_to?(:record) ? exception.record.errors.full_messages : [exception.message]
    render json: { error: errors }, status: :unprocessable_entity
  end

  def render_bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
