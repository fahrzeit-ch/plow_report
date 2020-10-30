# frozen_string_literal: true

class CreateDrives < ActiveRecord::Migration[5.1]
  def change
    create_table :drives do |t|
      t.datetime :start, null: false
      t.datetime :end, null: false
      t.float :distance_km, null: false, default: 0
      t.boolean :salt_refilled, null: false, default: false
      t.float :salt_amount_tonns, null: false, default: 0
      t.boolean :salted, null: false, default: false
      t.boolean :plowed, null: false, default: false

      t.timestamps
    end

    add_index :drives, [:start, :end]
  end
end
