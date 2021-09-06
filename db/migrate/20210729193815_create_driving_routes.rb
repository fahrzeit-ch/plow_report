class CreateDrivingRoutes < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE driving_route_sites_ordering AS ENUM ('order_by_distance', 'custom_order');
    SQL
    create_table :driving_routes do |t|
      t.string :name, null: false
      t.references :company, null: false, foreign_key: true
      t.column :site_ordering, :driving_route_sites_ordering, null: false
      t.datetime :discarded_at, index: true
      t.timestamps
    end

    create_table :driving_route_site_entries do |t|
      t.references :site, null: false, foreign_key: true
      t.references :driving_route, null: false, foreign_key: true
      t.integer :position, null: false
    end

    execute <<-SQL
      ALTER TABLE driving_route_site_entries ADD CONSTRAINT position_gte_zero CHECK ( position >= 0 );
    SQL

    execute <<-SQL
      alter table driving_route_site_entries
        add constraint driving_route_site_entries_position_unique unique (driving_route_id, position)
        DEFERRABLE INITIALLY DEFERRED;
    SQL

    add_index(:driving_routes, [:company_id, :name], unique: true)
    add_index(:driving_route_site_entries, [:position, :driving_route_id], name: :route_site_entries_index)
  end

  def down
    drop_table :driving_route_site_entries
    drop_table :driving_routes

    execute <<-SQL
      DROP TYPE driving_route_sites_ordering;
    SQL
  end
end
