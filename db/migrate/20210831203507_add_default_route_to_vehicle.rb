class AddDefaultRouteToVehicle < ActiveRecord::Migration[6.1]
  def change
    add_column :vehicles, :default_driving_route_id, :integer
    add_foreign_key :vehicles, :driving_routes, column: :default_driving_route_id, name: :fk_vehicles_driving_routes
  end
end
