class CreateStandbyDates < ActiveRecord::Migration[5.1]
  def change
    create_table :standby_dates do |t|
      t.date :day, null: false, index: true
      t.timestamps
    end
  end
end
