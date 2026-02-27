ActiveAdmin.register Order do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :first_name, :last_name, :email, :address, :postal_code, :city, :paid,
              order_items_attributes: [:id, :product_id, :price, :quantity, :_destroy]


  form do |f|
    f.semantic_errors 

    f.inputs "Customer Details" do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :address
      f.input :post_code
      f.input :city
      f.input :paid
    end

    f.inputs "Product in Order" do
      f.has_many :order_items, allow_destroy: true, new_record: true do |item|
        item.input :product
        item.input :quantity
        # item.input :price, input_html: { value: item.object.product&.price }
      end
    end

    f.actions
  end
  #
  # or
  #
  # permit_params do
  #   permitted = [:first_name, :last_name, :email, :address, :post_code, :city, :paid]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
