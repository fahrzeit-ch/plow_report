class Route::SiteEntry < ApplicationRecord
  self.table_name_prefix = 'route_'

  belongs_to :site
  belongs_to :route, inverse_of: :site_entries
end