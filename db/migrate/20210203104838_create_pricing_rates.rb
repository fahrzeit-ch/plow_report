class CreatePricingRates < ActiveRecord::Migration[5.2]
  def change
    create_table :pricing_hourly_rates do |t|
      t.references :hourly_ratable, polymorphic: true, index: { name: "index_hourly_rates_on_hourly_priceable_id" }
      t.integer :price_cents, null: false, default: 0
      t.string :price_currency, null: false
      t.date :valid_from, null: false

      t.timestamps
    end

    create_table :pricing_flat_rates do |t|
      t.references :flat_ratable, polymorphic: true, index: { name: "index_flat_rates_on_rable_id_ratable_type" }
      t.integer :price_cents, null: false, default: 0
      t.string :price_currency, null: false
      t.date :valid_from, null: false
      t.string :rate_type, null: false, default: Pricing::FlatRate::CUSTOM_FEE

      t.timestamps
    end

    add_index :pricing_flat_rates, [:flat_ratable_id, :flat_ratable_type, :rate_type], name: "index_flat_rates_on_rable_id_ratable_type_rate_type"
  end
end
