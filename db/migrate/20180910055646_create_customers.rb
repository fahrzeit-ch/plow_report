# frozen_string_literal: true

class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.references(:company)
      t.timestamps
    end

    add_index :customers, [:name, :company_id], unique: true
  end
end
