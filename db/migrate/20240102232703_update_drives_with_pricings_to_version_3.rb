class UpdateDrivesWithPricingsToVersion3 < ActiveRecord::Migration[6.1]
  def change
    update_view :drives_with_pricings, version: 3, revert_to_version: 2, materialized: true
  end
end
