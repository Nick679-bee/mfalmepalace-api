require "net/http"
require "json"
require "base64"

module Mpesa
  class Client
    def initialize
      @base_url = ENV.fetch("MPESA_BASE_URL", "https://sandbox.safaricom.co.ke")
      @consumer_key = ENV["MPESA_CONSUMER_KEY"]
      @consumer_secret = ENV["MPESA_CONSUMER_SECRET"]
      @short_code = ENV["MPESA_SHORTCODE"]
      @passkey = ENV["MPESA_PASSKEY"]
      @callback_url = ENV["MPESA_CALLBACK_URL"]
    end

    def stk_push(amount_cents:, phone_number:, account_reference:, transaction_desc:)
      validate_configuration!

      access_token = oauth_token
      timestamp = Time.current.strftime("%Y%m%d%H%M%S")
      password = Base64.strict_encode64("#{@short_code}#{@passkey}#{timestamp}")
      amount = [(amount_cents.to_i / 100), 1].max
      normalized_phone = normalize_phone(phone_number)

      payload = {
        BusinessShortCode: @short_code,
        Password: password,
        Timestamp: timestamp,
        TransactionType: "CustomerPayBillOnline",
        Amount: amount,
        PartyA: normalized_phone,
        PartyB: @short_code,
        PhoneNumber: normalized_phone,
        CallBackURL: @callback_url,
        AccountReference: account_reference,
        TransactionDesc: transaction_desc
      }

      response = http_post(
        "#{@base_url}/mpesa/stkpush/v1/processrequest",
        payload,
        "Authorization" => "Bearer #{access_token}"
      )

      body = JSON.parse(response.body)
      success = response.is_a?(Net::HTTPSuccess) && body["ResponseCode"] == "0"

      {
        success: success,
        merchant_request_id: body["MerchantRequestID"],
        checkout_request_id: body["CheckoutRequestID"],
        customer_message: body["CustomerMessage"],
        error_message: body["errorMessage"] || body["ResponseDescription"],
        raw: body
      }
    end

    private

    def validate_configuration!
      required = {
        "MPESA_CONSUMER_KEY" => @consumer_key,
        "MPESA_CONSUMER_SECRET" => @consumer_secret,
        "MPESA_SHORTCODE" => @short_code,
        "MPESA_PASSKEY" => @passkey,
        "MPESA_CALLBACK_URL" => @callback_url
      }
      missing = required.select { |_key, value| value.blank? }.keys
      raise "Missing M-Pesa configuration: #{missing.join(', ')}" if missing.any?
    end

    def oauth_token
      uri = URI("#{@base_url}/oauth/v1/generate?grant_type=client_credentials")
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(@consumer_key, @consumer_secret)
      response = perform_request(uri, request)
      body = JSON.parse(response.body)
      token = body["access_token"]
      raise "Unable to get M-Pesa access token" if token.blank?

      token
    end

    def http_post(url, payload, headers = {})
      uri = URI(url)
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      headers.each { |key, value| request[key] = value }
      request.body = payload.to_json
      perform_request(uri, request)
    end

    def perform_request(uri, request)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end
    end

    def normalize_phone(phone_number)
      digits = phone_number.to_s.gsub(/\D/, "")
      return digits.sub(/\A0/, "254") if digits.start_with?("0")
      return digits if digits.start_with?("254")

      digits
    end
  end
end
