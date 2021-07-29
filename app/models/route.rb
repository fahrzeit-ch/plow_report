# frozen_string_literal: true

# A preconfigured route including which sites
# to visit and how they should be ordered.
# The route is used in the app within the active tour
# screen to only show customer sites relevant to the selected route.
class Route < ApplicationRecord
  ORDER_BY_DISTANCE = "order_by_distance"
  CUSTOM_ORDER = "custom_order"

  belongs_to :company
  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :site_ordering, inclusion: [ORDER_BY_DISTANCE, CUSTOM_ORDER]

  has_many :site_entries, :class_name => 'Route::SiteEntry'
  accepts_nested_attributes_for :site_entries
end
