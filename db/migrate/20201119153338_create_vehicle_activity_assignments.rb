# frozen_string_literal: true

class CreateVehicleActivityAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :vehicle_activity_assignments do |t|
      t.references :vehicle, foreign_key: true
      t.references :activity, foreign_key: true

      t.timestamps
    end
  end
end
