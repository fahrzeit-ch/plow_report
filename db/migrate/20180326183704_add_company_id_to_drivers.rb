# frozen_string_literal: true

class AddCompanyIdToDrivers < ActiveRecord::Migration[5.1]
  def change
    add_column :drivers, :company_id, :integer, null: true

    add_foreign_key :drivers, :companies
  end
end
