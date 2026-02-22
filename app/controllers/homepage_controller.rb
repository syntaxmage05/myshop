class HomepageController < ApplicationController
  def index
    @categories = Category.all

    if params[:category_id]
      @selected_category = Category.find(params[:category_id])
      @products = @selected_category.products
    else
      @products = Product.all
    end
  end
end
