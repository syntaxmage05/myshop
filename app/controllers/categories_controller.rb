# frozen_string_literal: true

class CategoriesController < ApplicationController
  def show
    @categories = Category.all
    @category = Category.friendly.find(params[:id])
    @products = @category.products
  end
end
