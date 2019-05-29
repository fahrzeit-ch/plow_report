class AddIntegrityChecksForCustomerFields < ActiveRecord::Migration[5.1]
  def change
    change_column :customers, :name, :string, null: false
    change_column :customers, :first_name, :string, null: false, default: ''
    change_column :customers, :zip, :string, null: false, default: ''
    change_column :customers, :city, :string, null: false, default: ''
    change_column :customers, :nr, :string, null: false, default: ''
    change_column :customers, :street, :string, null: false, default: ''

    change_column :sites, :zip, :string, null: false, default: ''
    change_column :sites, :city, :string, null: false, default: ''
    change_column :sites, :nr, :string, null: false, default: ''
    change_column :sites, :street, :string, null: false, default: ''
  end
end
