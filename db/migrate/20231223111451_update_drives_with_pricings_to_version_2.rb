class UpdateDrivesWithPricingsToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :drives_with_pricings, version: 2, revert_to_version: 1, materialized: true
  end
end
