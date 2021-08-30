class DrivingRoute::SiteEntry < ApplicationRecord
  self.table_name_prefix = 'driving_route_'

  belongs_to :site
  belongs_to :driving_route, inverse_of: :site_entries
end