# frozen_string_literal: true

class CreatePolicyTerms < ActiveRecord::Migration[5.1]
  def change
    create_table :policy_terms do |t|
      t.string :key
      t.boolean :required
      t.text :short_description
      t.text :description
      t.string :name

      t.timestamps
    end
  end
end
