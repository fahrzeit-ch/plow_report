class AddAddressToCustomer < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :street, :string
    add_column :customers, :nr, :string
    add_column :customers, :zip, :string
    add_column :customers, :city, :string
  end
end
