# frozen_string_literal: true

# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  before_action :check_cart_not_empty, only: [:new, :create]
  before_action :set_order, only: [:thank_you, :mpesa_payment]

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)

    @cart.line_items.each do |line_item|
      @order.order_items.new(
        product: line_item.product,
        quantity: line_item.quantity,
        price: line_item.product.price
      )
    end

    if @order.save
      # Initialize M-Pesa service
      mpesa_service = MpesaService.new
      response = mpesa_service.stk_push(@order.phone, @order.total_cost, @order.id)

      if response && response["ResponseCode"] == "0"
        # Create transaction record
        @order.create_mpesa_transaction(
          checkout_request_id: response["CheckoutRequestID"],
          merchant_request_id: response["MerchantRequestID"],
          amount: @order.total_cost,
          phone_number: @order.phone,
          status: "PENDING"
        )

        # Clear the cart
        @cart.destroy
        session[:cart_id] = nil

        # Redirect to payment page
        redirect_to mpesa_payment_order_path(@order)
      else
        # Payment initiation failed, but order is saved
        @cart.destroy
        session[:cart_id] = nil

        redirect_to thank_you_order_path(@order),
          alert: "Order placed but payment could not be initiated. You can complete payment later from your orders."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def thank_you
    @order = Order.find(params[:id])
  end

  def mpesa_payment
    @order = Order.find(params[:id])
    @transaction = @order.mpesa_transaction

    if @transaction.nil?
      redirect_to thank_you_order_path(@order), alert: "No payment transaction found for this order."
    end
  end

  private

    def order_params
      params.require(:order).permit(:first_name, :last_name, :email, :phone, :address, :post_code, :city)
    end

    def check_cart_not_empty
      if @cart.line_items.empty?
        redirect_to cart_path(@cart), alert: "Your cart is empty"
      end
    end

    def set_order
      @order = Order.find(params[:id])
    end
end
