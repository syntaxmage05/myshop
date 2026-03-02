# frozen_string_literal: true

class OrderMailerPreview < ActionMailer::Preview
  # Preview for the order confirmation email
  def confirmation_order
    # Use an existing order or build a sample
    order = Order.first || Order.new(
      first_name: "Fred",
      last_name: "Njonge",
      email: "frednjonge9@gmail.com",
      address: "123 Main St",
      post_code: "00100",
      city: "Nairobi"
    )

    OrderMailer.confirmation_order(order)
  end
end
