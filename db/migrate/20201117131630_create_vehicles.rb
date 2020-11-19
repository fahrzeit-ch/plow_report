# frozen_string_literal: true

class CreateVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :vehicles do |t|
      t.string :name, index: true
      t.datetime :discarded_at, index: true
      t.references :company

      t.timestamps
    end
  end
end
