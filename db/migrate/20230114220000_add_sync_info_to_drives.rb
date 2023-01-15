class AddSyncInfoToDrives < ActiveRecord::Migration[6.1]
  def change
    add_column :drives, :app_drive_id, :integer
    add_index :drives, [:tour_id, :app_drive_id], unique: true
  end
end
