# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  def confirmation_order(order)
    @order = order
    @order_items = order.order_items.includes(:product)

    mail(
      to: @order.email,
      subject: "Order ##{@order.id} Confirmation"
    )
  end
end
