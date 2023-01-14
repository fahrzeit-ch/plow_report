class AddSyncDatesToToursAndDrives < ActiveRecord::Migration[6.1]
  def change
    add_column :drives, :first_sync_at, :datetime, null: true
    add_column :drives, :last_sync_at, :datetime, null: true
    add_column :tours, :first_sync_at, :datetime, null: true
    add_column :tours, :last_sync_at, :datetime, null: true
  end
end
