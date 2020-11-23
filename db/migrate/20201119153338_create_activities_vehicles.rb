# frozen_string_literal: true

class CreateActivitiesVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :activities_vehicles do |t|
      t.references :vehicle, foreign_key: true
      t.references :activity, foreign_key: true

      t.timestamps
    end
  end
end
