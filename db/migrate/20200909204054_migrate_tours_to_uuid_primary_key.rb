class MigrateToursToUuidPrimaryKey < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'pgcrypto'

    remove_column :drives, :tour_id
    drop_table :tours

    create_table :tours, id: :uuid do |t|
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.references :driver, foreign_key: true, null: false
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :tours, :start_time
    add_index :tours, :discarded_at

    change_table :drives do |t|
      t.references :tour, foreign_key: true, type: :uuid
    end
  end
end
