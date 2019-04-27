class CreateImplicitHourlyRates < ActiveRecord::Migration[5.1]
  def change
    create_view :implicit_hourly_rates
  end
end
