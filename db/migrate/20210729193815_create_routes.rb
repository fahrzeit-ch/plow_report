class CreateRoutes < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE route_sites_ordering AS ENUM ('order_by_distance', 'custom_order');
    SQL
    create_table :routes do |t|
      t.string :name, null: false
      t.references :company, null: false, foreign_key: true
      t.column :site_ordering, :route_sites_ordering, null: false

      t.timestamps
    end

    create_table :route_site_entries do |t|
      t.references :site, null: false, foreign_key: true
      t.references :route, null: false, foreign_key: true
      t.integer :position, null: false
    end

    execute <<-SQL
      ALTER TABLE route_site_entries ADD CONSTRAINT position_gte_zero CHECK ( position >= 0 );
    SQL

    add_index(:routes, [:company_id, :name], unique: true)
    add_index(:route_site_entries, [:position, :route_id], unique: true)
  end

  def down
    drop_table :route_site_entries
    drop_table :routes

    execute <<-SQL
      DROP TYPE route_sites_ordering;
    SQL
  end
end
