# frozen_string_literal: true

class AddAreaJsonToSites < ActiveRecord::Migration[5.1]
  def change
    add_column :sites, :area_json, :json, null: false, default: {}
  end
end
