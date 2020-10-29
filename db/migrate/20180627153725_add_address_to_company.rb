# frozen_string_literal: true

class AddAddressToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :address, :string, null: false, default: ""
    add_column :companies, :zip_code, :string, null: false, default: ""
    add_column :companies, :city, :string, null: false, default: ""
  end
end
