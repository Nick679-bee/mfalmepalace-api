class PaymentsController < ActionController::API
  # No auth; provider webhooks
  def mpesa_stk_push
    booking = Booking.find(params.require(:booking_id))
    phone_number = params.require(:phone_number)

    result = Mpesa::Client.new.stk_push(
      amount_cents: booking.price_cents,
      phone_number: phone_number,
      account_reference: "BOOKING-#{booking.id}",
      transaction_desc: "Mfalme Palace booking ##{booking.id}"
    )

    unless result[:success]
      return render json: { error: result[:error_message] || "Failed to initiate M-Pesa payment" }, status: :unprocessable_entity
    end

    payment = booking.payments.create!(
      provider: "mpesa",
      provider_payment_id: result[:checkout_request_id],
      amount_cents: booking.price_cents,
      status: "pending",
      metadata: {
        merchant_request_id: result[:merchant_request_id],
        checkout_request_id: result[:checkout_request_id],
        customer_message: result[:customer_message],
        phone_number: phone_number,
        response: result[:raw]
      }
    )

    render json: {
      payment_id: payment.id,
      checkout_request_id: result[:checkout_request_id],
      merchant_request_id: result[:merchant_request_id],
      message: result[:customer_message] || "M-Pesa prompt sent",
      status: "pending"
    }, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Booking not found" }, status: :not_found
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :bad_request
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def webhook
    provider = params[:provider]
    case provider
    when 'stripe'
      handle_stripe_webhook
    when 'mpesa'
      handle_mpesa_webhook
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

  def handle_mpesa_webhook
    callback = params.dig("Body", "stkCallback") || {}
    checkout_request_id = callback["CheckoutRequestID"]
    result_code = callback["ResultCode"].to_i

    payment = Payment.find_by(provider: "mpesa", provider_payment_id: checkout_request_id)
    return head :ok unless payment

    metadata = payment.metadata || {}
    metadata["mpesa_callback"] = callback

    if result_code.zero?
      payment.update!(status: "succeeded", metadata: metadata)
      payment.booking.update!(status: "confirmed")
    else
      payment.update!(status: "failed", metadata: metadata)
      payment.booking.update!(status: "pending")
    end

    head :ok
  end
end

