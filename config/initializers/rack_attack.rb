class Rack::Attack
  # Throttle requests by IP (60 req/minute)
  throttle('req/ip', limit: 60, period: 1.minute) do |req|
    req.ip
  end

  # Allow health checks without throttling
  safelist('allow-localhost-health') do |req|
    req.path == '/up'
  end
end

Rails.application.config.middleware.use Rack::Attack

