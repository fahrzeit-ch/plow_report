class AddDiscardedAtToDrives < ActiveRecord::Migration[5.1]
  def change
    add_column :drives, :discarded_at, :datetime
    add_index :drives, :discarded_at
  end
end
