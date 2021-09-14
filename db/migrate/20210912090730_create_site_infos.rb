class CreateSiteInfos < ActiveRecord::Migration[6.1]
  def change
    create_table :site_infos do |t|
      t.references :site, null: false, foreign_key: true
      t.datetime :discarded_at
      t.text :content

      t.timestamps
    end
  end
end
