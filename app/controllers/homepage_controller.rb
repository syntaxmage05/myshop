# frozen_string_literal: true

# app/controllers/homepage_controller.rb
class HomepageController < ApplicationController
  def index
    # Load categories with counter cache (no need for products association)
    @categories = Category.all.order(:name)

    # Base products query with eager loading
    products = if params[:category_id].present?
      category = Category.find_by(id: params[:category_id])
      category ? category.products : Product.none
    else
      Product.all
    end

    # Apply search
    if params[:search].present?
      products = products.where(
        "name ILIKE ? OR description ILIKE ?",
        "%#{params[:search]}%", "%#{params[:search]}%")
    end

    # Apply price range
    if params[:min_price].present?
      products = products.where("price >= ?", params[:min_price])
    end

    if params[:max_price].present?
      products = products.where("price <= ?", params[:max_price])
    end

    # Eager load associations to avoid N+1 queries
    products = products.includes(:category, :image_attachment)

    # Apply sorting
    @products = case params[:sort]
                when "newest"
                  products.order(created_at: :desc)
                when "price_low"
                  products.order(price: :asc)
                when "price_high"
                  products.order(price: :desc)
    else
                  products.order(created_at: :desc)
    end

    # Total products count for "All Products" button
    @total_products_count = Product.count
  end
end
