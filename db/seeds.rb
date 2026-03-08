# frozen_string_literal: true

require "open-uri"

puts "Cleaning database..."
Product.destroy_all
Category.destroy_all
User.destroy_all

User.create!(
  email: "admin@example.com", password: "password",
  password_confirmation: "password") if Rails.env.development?

puts "Creating categories..."

10.times do
  Category.create!(
    name: Faker::Commerce.department(max: 1)
  )
end

categories = Category.all

puts "Creating products..."

400.times do
  product = Product.create!(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price: Faker::Commerce.price(range: 500..5000.0),
    available: [true, true, false, true].sample,
    category: categories.sample
  )

  file = URI.open("https://picsum.photos/600/600?random=#{rand(1000)}")

  product.image.attach(
    io: file,
    filename: "product_#{rand(1000)}.jpg",
    content_type: "image/jpg"
  )
end

puts "Done!"
