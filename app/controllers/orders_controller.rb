class OrdersController < ApplicationController
  before_action :check_cart_not_empty, only: [:new, :create]

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)

    @cart.line_items.each do |line_item|
      @order.order_items.new(
        product: line_item.product,
        quantity: line_item.quantity,
        # cost: line_item.product.price * line_item.quantity
      )
    end

    if @order.save
      @cart.destroy
      session[:cart_id] = nil
      redirect_to thank_you_order_path(@order)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def thank_you
    @order = Order.find(params[:id])
  end

  private

  def order_params
    params.expect(order: [:first_name, :last_name, :email, :address, :post_code, :city])
  end

  def check_cart_not_empty
    if @cart.line_items.empty?
      redirect_to root_path, alert: "Your cart is empty"
    end
  end
end
