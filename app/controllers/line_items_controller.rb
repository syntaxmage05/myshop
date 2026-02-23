# frozen_string_literal: true

class LineItemsController < ApplicationController
  include CurrentCart
  before_action :set_cart, only: %i[ create ]

  def create
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    @line_item = @current_cart.add_product(product)
    @line_item.quantity += (quantity - 1) if quantity > 1

    respond_to do |format|
      if @line_item.save
        format.html { redirect_to @current_cart, notice: "Added to the cart" }
      else
        format.html { redirect_to root_path, alert: "Could not add product" }
      end
    end
  end

  private

    def set_cart
      @current_cart = Cart.find_by(id: session[:cart_id])

      unless @current_cart
        @current_cart = Cart.create
        session[:cart_id] = @current_cart.id
      end
    end
end
