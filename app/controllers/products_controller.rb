# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :set_product, only: [ :show ]

  def index
    @products = Product.all
    
    # Filter by category if category_id is present
    if params[:category_id].present?
      @category = Category.find_by(id: params[:category_id])
      @products = @products.where(category_id: params[:category_id]) if @category
    end
    
    # Filter by search query
    if params[:search].present?
      @products = @products.where("name ILIKE ? OR description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    # Filter by deals
    # if params[:deals].present?
    #   @products = @products.where(on_sale: true) # Assuming you have an on_sale boolean field
    # end
    
    # Sorting
    case params[:sort]
    when 'newest'
      @products = @products.order(created_at: :desc)
    when 'price_low'
      @products = @products.order(price: :asc)
    when 'price_high'
      @products = @products.order(price: :desc)
    when 'popular'
      @products = @products.left_joins(:order_items).group(:id).order('COUNT(order_items.id) DESC')
    else
      @products = @products.order(created_at: :desc)
    end
    
    # Pagination (if using pagy or will_paginate)
    # @products = @products.page(params[:page]).per(12)
  end

  def show
  end

  private

    def set_product
      @product = Product.friendly.find(params[:id])
    end
end
