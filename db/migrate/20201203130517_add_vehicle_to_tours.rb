class AddVehicleToTours < ActiveRecord::Migration[5.2]
  def change
    add_reference :tours, :vehicle, foreign_key: true
  end
end
