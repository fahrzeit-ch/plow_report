# frozen_string_literal: true

class CreateSites < ActiveRecord::Migration[5.1]
  def change
    create_table :sites do |t|
      t.string :name
      t.string :street
      t.string :nr
      t.string :zip
      t.string :city
      t.references :customer, foreign_key: true
      t.boolean :active

      t.timestamps
    end
  end
end
