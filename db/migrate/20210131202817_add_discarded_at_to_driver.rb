class AddDiscardedAtToDriver < ActiveRecord::Migration[5.2]
  def change
    add_column :drivers, :discarded_at, :datetime
    add_index :drivers, [:discarded_at]
  end
end
