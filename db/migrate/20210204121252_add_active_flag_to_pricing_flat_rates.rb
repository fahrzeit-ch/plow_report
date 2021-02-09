class AddActiveFlagToPricingFlatRates < ActiveRecord::Migration[5.2]
  def change
    add_column :pricing_flat_rates, :active, :boolean, default: false
  end
end
