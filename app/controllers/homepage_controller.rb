# app/controllers/homepage_controller.rb
# frozen_string_literal: true

class HomepageController < ApplicationController
  def index
    @categories = Category.all.order(:name)
    
    # Base products query
    products = if params[:category_id].present?
      category = Category.find_by(id: params[:category_id])
      category ? category.products : Product.none
    else
      Product.all
    end
    
    # Apply search
    if params[:search].present?
      products = products.where("name ILIKE ? OR description ILIKE ?", 
                              "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    # Apply price range
    if params[:min_price].present?
      products = products.where("price >= ?", params[:min_price])
    end
    
    if params[:max_price].present?
      products = products.where("price <= ?", params[:max_price])
    end
    
    # Apply sorting
    @products = case params[:sort]
    when 'popular'
      # Count how many times each product appears in order_items
      products.left_joins(:order_items)
              .group('products.id')
              .select('products.*, COUNT(order_items.id) as orders_count')
              .order('orders_count DESC, products.created_at DESC')
    when 'newest'
      products.order(created_at: :desc)
    when 'price_low'
      products.order(price: :asc)
    when 'price_high'
      products.order(price: :desc)
    else
      products.order(created_at: :desc)
    end
    
    # For the "All Products" count in sidebar - use a separate query
    @total_products_count = Product.count
  end
end