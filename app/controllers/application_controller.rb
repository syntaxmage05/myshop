# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include CurrentCart
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_cart
  before_action :load_categories_for_navbar
  helper_method :cart

  private

    def cart
      @cart
    end

    def load_categories_for_navbar
      @categories = Category.all.limit(8) # Limit for dropdown
    end
end
