class CreateRecordings < ActiveRecord::Migration[5.1]
  def change
    create_table :recordings do |t|
      t.datetime :start_time, null: false
      t.references :driver, index: { unique: true }
    end
  end
end
