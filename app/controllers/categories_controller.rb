# frozen_string_literal: true

class CategoriesController < ApplicationController
  def show
    @categories = Category.all
    @category = Category.friendly.find(params[:id])
    @products = @category.products
      .includes(:category, image_attachment: :blob) # Add eager loading
      .order(created_at: :desc)
  end
end
