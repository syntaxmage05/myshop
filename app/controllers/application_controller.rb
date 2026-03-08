# frozen_string_literal: true

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include CurrentCart
  allow_browser versions: :modern
  before_action :set_cart
  before_action :load_categories_for_navbar
  helper_method :cart

  private

    def cart
      @cart
    end

    def load_categories_for_navbar
      # Load categories for the navbar dropdown
      @categories = Category.all.order(:name).limit(8)
    end
end
