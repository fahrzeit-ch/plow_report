# frozen_string_literal: true

class SetActiveStatusToDefaultTrue < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:sites, :active, true)
  end
end
