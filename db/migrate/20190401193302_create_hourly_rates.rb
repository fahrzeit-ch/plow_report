# frozen_string_literal: true

class CreateHourlyRates < ActiveRecord::Migration[5.1]
  def change
    create_table :hourly_rates do |t|
      t.integer :price_cents, null: false, default: 0
      t.string :price_currency, null: false
      t.references :activity, foreign_key: true
      t.references :customer, foreign_key: true
      t.references :company, foreign_key: true, null: false

      t.date :valid_from, null: false, default: Date.new(2000, 1, 1)
      t.date :valid_until, null: false, default: Date.new(2100, 1, 1)
      t.timestamps
      t.index :valid_from
      t.index :valid_until
    end
  end
end
