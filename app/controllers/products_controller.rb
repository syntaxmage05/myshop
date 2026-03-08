# frozen_string_literal: true

# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  def index
    # Base query with eager loading
    @products = Product.all
      .includes(:category, :image_attachment)
      .order(created_at: :desc)

    # Filter by category if category_id is present
    if params[:category_id].present?
      @category = Category.find_by(id: params[:category_id])
      @products = @products.where(category_id: params[:category_id]) if @category
    end

    # Filter by search query
    if params[:search].present?
      @products = @products.where(
        "name ILIKE ? OR description ILIKE ?",
        "%#{params[:search]}%", "%#{params[:search]}%")
    end

    # Filter by price range
    if params[:min_price].present?
      @products = @products.where("price >= ?", params[:min_price])
    end

    if params[:max_price].present?
      @products = @products.where("price <= ?", params[:max_price])
    end

    # Sorting
    case params[:sort]
    when "newest"
      @products = @products.order(created_at: :desc)
    when "price_low"
      @products = @products.order(price: :asc)
    when "price_high"
      @products = @products.order(price: :desc)
    when "popular"
      @products = @products.left_joins(:order_items)
        .group("products.id")
        .select("products.*, COUNT(order_items.id) as orders_count")
        .order("orders_count DESC, products.created_at DESC")
    else
      @products = @products.order(created_at: :desc)
    end
  end

  def show
    # @product is set by set_product with eager loading

    # Load related products with eager loading to avoid N+1 queries
    @related_products = Product.where(category_id: @product.category_id)
      .where.not(id: @product.id)
      .includes(:image_attachment) # FIX: Eager load images
      .limit(4)
  end

  private

    def set_product
      @product = Product.includes(:category, :image_attachment) # FIX: Eager load associations
        .friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to products_path, alert: "Product not found"
    end
end
