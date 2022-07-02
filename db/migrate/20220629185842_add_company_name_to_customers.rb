class AddCompanyNameToCustomers < ActiveRecord::Migration[6.1]
  def change
    add_column :customers, :company_name, :string, default: "", null: false
    add_index :customers, [:company_name, :name]
  end
end
