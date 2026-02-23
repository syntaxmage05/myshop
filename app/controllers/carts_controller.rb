# frozen_string_literal: true

class CartsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_cart

  def show
    @cart = Cart.find(session[:cart_id])
  end

  def destroy
    @cart = Cart.find_by(id: session[:cart_id])
    @cart.destroy if session[:cart_id]
    session[:cart_id] = nil
    redirect_to root_path, notice: "Your cart is empty"
  end

  private

    def invalid_cart
      logger.error "Invalid cart #{params[:id]}"
      redirect_to root_path, alert: "Invalid cart"
    end
end
