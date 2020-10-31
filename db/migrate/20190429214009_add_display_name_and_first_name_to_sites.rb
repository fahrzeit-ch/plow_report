# frozen_string_literal: true

class AddDisplayNameAndFirstNameToSites < ActiveRecord::Migration[5.1]
  def up
    add_column :sites, :display_name, :string, null: false, default: ""
    add_column :sites, :first_name, :string, null: false, default: ""
    add_index :sites, [:display_name]
    execute "UPDATE sites SET display_name = name;"
  end

  def down
    remove_index :sites, [:display_name]
    remove_column :sites, :display_name
    remove_column :sites, :first_name
  end
end
