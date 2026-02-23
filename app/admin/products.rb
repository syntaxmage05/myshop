# frozen_string_literal: true

ActiveAdmin.register Product do
  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      scoped_collection.find(params[:id])
    end
  end
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name, :description, :price, :available, :category_id, :image

  filter :category
  filter :name
  filter :price
  filter :available

  form do |f|
    inputs "Product Details" do
      input :name
      input :description
      input :price
      input :available
      input :category
      input :image, as: :file
    end
    actions
  end

  show do
    attributes_table_for resource do
      row :name
      row :description
      row :price
      row :available
      row :image do
        if resource.image.attached?
          image_tag product.image.variant(resize_to_limit: [ 200, 200 ])
        end
      end
    end
  end
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :description, :price, :available, :category_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
