class CreateUniqueIndexForDriverId < ActiveRecord::Migration[5.1]
  def change
    add_index :driver_logins, :driver_id, unique: true, name: 'uniq_index_driver_logins_on_driver_id'
  end
end
