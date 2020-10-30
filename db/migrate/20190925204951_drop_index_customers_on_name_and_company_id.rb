# frozen_string_literal: true

class DropIndexCustomersOnNameAndCompanyId < ActiveRecord::Migration[5.1]
  def change
    remove_index :customers, column: [:name, :company_id]
  end
end
