class AddFirstNameToCustomers < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :first_name, :string
  end
end
