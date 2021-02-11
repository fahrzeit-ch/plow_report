class CreateSiteActivityFlatRates < ActiveRecord::Migration[5.2]
  def change
    create_table :site_activity_flat_rates do |t|
      t.references :site, foreign_key: true
      t.references :activity, foreign_key: true

      t.timestamps
    end
  end
end
