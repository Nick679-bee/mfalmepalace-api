class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]

  def create
    user = User.find_by(email: params.require(:email))
    if user&.authenticate(params.require(:password))
      token = JWT.encode({ user_id: user.id, role: user.role, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base, 'HS256')
      render json: { token:, user: { id: user.id, name: user.name, email: user.email, role: user.role } }, status: :created
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end

