# frozen_string_literal: true

class CreateDrivers < ActiveRecord::Migration[5.1]
  def up
    create_table :drivers do |t|
      t.string :name
      t.timestamps
    end

    add_column :drives, :driver_id, :integer, null: false
    add_foreign_key :drives, :drivers, name: "fk_drives_driver"

    add_column :standby_dates, :driver_id, :integer, null: false
    add_foreign_key :standby_dates, :drivers, name: "fk_standby_dates_driver"

    create_table :driver_logins do |t|
      t.references :driver, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps
    end

    add_index :driver_logins, [:driver_id, :user_id], unique: true
  end

  def down
    remove_column :drives, :driver_id
    remove_column :standby_dates, :driver_id

    remove_index :driver_logins, [:driver_id, :user_id]

    drop_table :driver_logins
    drop_table :drivers
  end
end
