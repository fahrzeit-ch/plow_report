# frozen_string_literal: true

class AddStreetNrToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :nr, :string, null: false, default: ""
  end
end
