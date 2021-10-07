class CreateJoinTableSiteActivity < ActiveRecord::Migration[6.1]
  def change
    create_join_table :sites, :activities do |t|
      t.index [:site_id, :activity_id]
      t.index [:activity_id, :site_id]
    end
  end
end
