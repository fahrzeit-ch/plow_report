class CreateJoinTableRoutesVehicles < ActiveRecord::Migration[6.1]
  def change
    create_join_table :driving_routes, :vehicles do |t|
      t.index [:vehicle_id, :driving_route_id], name: :idx_vehicle_id_driving_route_id
      t.index [:driving_route_id, :vehicle_id], name: :idx_driving_route_id_vehicle_id
    end
  end
end
