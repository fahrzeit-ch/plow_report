class CreateTours < ActiveRecord::Migration[5.1]
  def change
    create_table :tours do |t|
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.references :driver, foreign_key: true, null: false

      t.timestamps
    end

    change_table :drives do |t|
      t.references :tour, foreign_key: true
    end
  end
end
