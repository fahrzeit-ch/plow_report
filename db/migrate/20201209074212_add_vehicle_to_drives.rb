class AddVehicleToDrives < ActiveRecord::Migration[5.2]
  def change
    add_reference :drives, :vehicle, foreign_key: true
  end
end
