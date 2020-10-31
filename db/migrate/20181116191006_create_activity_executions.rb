# frozen_string_literal: true

class CreateActivityExecutions < ActiveRecord::Migration[5.1]
  def change
    create_table :activity_executions do |t|
      t.references :activity, foreign_key: true
      t.references :drive, foreign_key: true
      t.decimal :value
      t.timestamps
    end
  end
end
