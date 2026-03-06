# frozen_string_literal: true

# app/controllers/mpesa_controller.rb
class MpesaController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  skip_before_action :set_cart, only: [:callback]

  def callback
    data = JSON.parse(request.body.read)
    Rails.logger.info "=" * 50
    Rails.logger.info "M-Pesa Callback Received"
    Rails.logger.info "Time: #{Time.current}"
    Rails.logger.info "Data: #{JSON.pretty_generate(data)}"
    Rails.logger.info "=" * 50

    # Find transaction by CheckoutRequestID
    checkout_request_id = data.dig("Body", "stkCallback", "CheckoutRequestID")
    transaction = MpesaTransaction.find_by(checkout_request_id: checkout_request_id)

    if transaction
      result = data["Body"]["stkCallback"]
      result_code = result["ResultCode"]

      if result_code == 0
        # Payment successful - extract metadata
        metadata = result["CallbackMetadata"]["Item"]
        receipt = metadata.find { |item| item["Name"] == "MpesaReceiptNumber" }["Value"]
        amount = metadata.find { |item| item["Name"] == "Amount" }["Value"]
        phone = metadata.find { |item| item["Name"] == "PhoneNumber" }["Value"]

        # Update transaction and order
        transaction.update(
          status: "COMPLETED",
          result_code: result_code,
          result_desc: result["ResultDesc"],
          mpesa_receipt_number: receipt
        )
        transaction.order.mark_as_paid!

        Rails.logger.info "Payment successful for Order ##{transaction.order.id}, Receipt: #{receipt}"
      else
        # Payment failed
        transaction.update(
          status: "FAILED",
          result_code: result_code,
          result_desc: result["ResultDesc"]
        )
        Rails.logger.error "Payment failed: #{result['ResultDesc']}"
      end
    else
      Rails.logger.error "Transaction not found for CheckoutRequestID: #{checkout_request_id}"
    end

    # Always respond with success to M-Pesa
    render json: { ResultCode: 0, ResultDesc: "Success" }
  end

  def status
    transaction = MpesaTransaction.find(params[:id])

    render json: {
      status: transaction.status,
      result_desc: transaction.result_desc,
      mpesa_receipt_number: transaction.mpesa_receipt_number
    }
  end
end
