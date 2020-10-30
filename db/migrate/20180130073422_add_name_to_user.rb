# frozen_string_literal: true

class AddNameToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :name, :string, default: "", null: false
    add_column :users, :driver_id, :integer, null: true
  end
end
