class DropHourlyRates < ActiveRecord::Migration[5.2]
  def change
    drop_view :implicit_hourly_rates
    drop_table :hourly_rates
  end
end
