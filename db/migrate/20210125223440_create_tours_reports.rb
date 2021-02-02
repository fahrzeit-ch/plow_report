class CreateToursReports < ActiveRecord::Migration[5.2]
  def change
    create_table :tours_reports do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.integer :created_by_id, index: true
      t.references :company

      t.timestamps
    end
  end
end
