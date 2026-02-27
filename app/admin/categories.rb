# frozen_string_literal: true

ActiveAdmin.register Category do
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
  permit_params :name

  form do |f|
    inputs "Category Details" do
      input :name
    end
    actions
  end

  show do
    panel "Products in this Category" do
      table_for category.products do
        column :name
        column :price
        column :available
        column :created_at
        column do |product|
          link_to "View", admin_product_path(product)
        end
      end
  
      div do
        link_to "Add New Product", 
                new_admin_product_path(products: { category_id: category.id}), 
                class: "button"
      end
    end
  end

  #
  # or
  #
  # permit_params do
  #   permitted = [:name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
