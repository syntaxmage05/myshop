# frozen_string_literal: true

# app/services/mpesa_service.rb
class MpesaService
  def initialize
    validate_config!

    Rails.logger.info "=" * 50
    Rails.logger.info "M-Pesa Service Initialized"
    Rails.logger.info "Shortcode: #{ENV['business_short_code']}"
    Rails.logger.info "Callback URL: #{ENV['callback_url']}"
    Rails.logger.info "=" * 50
  end

  def stk_push(phone_number, amount, order_id, account_reference = nil)
    # Format phone number correctly for M-Pesa API
    phone = format_phone_for_mpesa(phone_number)

    Rails.logger.info "=" * 50
    Rails.logger.info "STK Push Request"
    Rails.logger.info "Original Phone: #{phone_number}"
    Rails.logger.info "Formatted Phone: #{phone}"
    Rails.logger.info "Amount: #{amount}"
    Rails.logger.info "Order ID: #{order_id}"
    Rails.logger.info "=" * 50

    # The gem expects amount as string and phone as 254XXXXXXXXX format
    response = MpesaStk::PushPayment.call(amount.to_s, phone)

    Rails.logger.info "STK Push Response: #{response.inspect}"

    if response && response["ResponseCode"] == "0"
      {
        "ResponseCode" => response["ResponseCode"],
        "ResponseDescription" => response["ResponseDescription"],
        "CheckoutRequestID" => response["CheckoutRequestID"],
        "MerchantRequestID" => response["MerchantRequestID"],
        "CustomerMessage" => response["CustomerMessage"]
      }
    else
      error_message = response&.dig("errorMessage") || response&.dig("error") || "Failed to initiate payment"
      Rails.logger.error "STK Push failed: #{error_message}"
      { "error" => error_message }
    end
  rescue StandardError => e
    Rails.logger.error "M-Pesa service error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n") if e.backtrace
    { "error" => e.message }
  end

  def query_status(checkout_request_id)
    Rails.logger.info "Querying status for: #{checkout_request_id}"

    response = MpesaStk::StkPushQuery.query(checkout_request_id)

    Rails.logger.info "Query Response: #{response.inspect}"

    if response && response["ResponseCode"] == "0"
      {
        "ResponseCode" => response["ResponseCode"],
        "ResponseDescription" => response["ResponseDescription"],
        "ResultCode" => response["ResultCode"],
        "ResultDesc" => response["ResultDesc"],
        "CheckoutRequestID" => response["CheckoutRequestID"]
      }
    else
      { "error" => response&.dig("errorMessage") || "Query failed" }
    end
  rescue StandardError => e
    Rails.logger.error "Query status error: #{e.message}"
    { "error" => e.message }
  end

  private

    def format_phone_for_mpesa(phone)
      # Remove all non-digit characters
      phone = phone.to_s.gsub(/\D/, "")

      # M-Pesa API expects phone in format: 2547XXXXXXXX (no leading zero)
      if phone.start_with?("0")
        # Convert 07XXXXXXXX to 2547XXXXXXXX
        "254#{phone[1..-1]}"
      elsif phone.start_with?("254")
        # Already in correct format
        phone
      elsif phone.length == 9
        # If it's 712345678, add 254
        "254#{phone}"
      else
        # Default: assume it's a valid number and add 254
        "254#{phone}"
      end
    end

    def validate_config!
      required_vars = %w[key secret business_short_code business_passkey callback_url]
      missing = required_vars.select { |var| ENV[var].blank? }

      if missing.any?
        error_msg = "Missing M-Pesa configuration in ENV: #{missing.join(', ')}"
        Rails.logger.error error_msg
        raise StandardError, error_msg
      end

      Rails.logger.info "M-Pesa Config Loaded:"
      Rails.logger.info "  business_short_code: #{ENV['business_short_code']}"
      Rails.logger.info "  callback_url: #{ENV['callback_url']}"
      Rails.logger.info "  till_number: #{ENV['till_number']}"
    end
end
