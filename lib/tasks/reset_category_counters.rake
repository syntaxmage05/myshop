task reset_category_counter: :environment do
  Category.all.each do |category|
    Category.reset_counters(category.id, :products)
  end
end