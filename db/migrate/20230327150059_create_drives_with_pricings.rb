class CreateDrivesWithPricings < ActiveRecord::Migration[6.1]
  def change
    create_view :drives_with_pricings, materialized: true

    add_index :drives_with_pricings, :customer_id
    add_index :drives_with_pricings, :start
  end
end
