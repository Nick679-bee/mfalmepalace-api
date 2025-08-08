class PaymentsController < ActionController::API
  # No auth; provider webhooks
  def webhook
    provider = params[:provider]
    case provider
    when 'stripe'
      handle_stripe_webhook
    else
      head :bad_request
    end
  end

  private

  def handle_stripe_webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      return head :bad_request
    end

    case event['type']
    when 'payment_intent.succeeded'
      pi = event['data']['object']
      payment = Payment.find_by(provider: 'stripe', provider_payment_id: pi['id'])
      payment&.update(status: 'succeeded', metadata: pi)
    when 'payment_intent.payment_failed'
      pi = event['data']['object']
      payment = Payment.find_by(provider: 'stripe', provider_payment_id: pi['id'])
      payment&.update(status: 'failed', metadata: pi)
    end

    head :ok
  end
end

