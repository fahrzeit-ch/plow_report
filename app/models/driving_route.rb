# frozen_string_literal: true

# A preconfigured route including which sites
# to visit and how they should be ordered.
# The route is used in the app within the active tour
# screen to only show customer sites relevant to the selected route.
class DrivingRoute < ApplicationRecord
  ORDER_BY_DISTANCE = "order_by_distance"
  CUSTOM_ORDER = "custom_order"

  include Discard::Model
  include ChangedSince

  belongs_to :company
  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :site_ordering, inclusion: [ORDER_BY_DISTANCE, CUSTOM_ORDER]

  has_many :site_entries, -> { order(:position) }, :class_name => 'DrivingRoute::SiteEntry', inverse_of: :driving_route
  accepts_nested_attributes_for :site_entries, allow_destroy: true, reject_if: :all_blank
end
