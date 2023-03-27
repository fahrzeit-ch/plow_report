namespace :materialized_views do
  desc "refreshes materialized views"
  task refresh: :environment do
    Scenic.database.refresh_materialized_view(:drives_with_pricings, concurrently: false, cascade: false)
  end
end
