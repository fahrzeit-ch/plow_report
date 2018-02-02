class RemoveDriverIdFromUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :driver_id
  end
end
