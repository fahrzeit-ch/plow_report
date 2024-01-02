class UpdateDrivesWithPricingsToVersion4 < ActiveRecord::Migration[6.1]
  def change
    update_view :drives_with_pricings, version: 4, revert_to_version: 3, materialized: true
  end
end
