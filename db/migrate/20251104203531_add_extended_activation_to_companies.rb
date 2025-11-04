class AddExtendedActivationToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :extended_activation, :boolean, default: false
  end
end
