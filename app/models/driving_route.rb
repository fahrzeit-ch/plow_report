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
  has_many :vehicles, inverse_of: :default_driving_route, dependent: :nullify, foreign_key: :default_driving_route_id

  has_many :site_entries, -> { order(:position) }, :class_name => 'DrivingRoute::SiteEntry', inverse_of: :driving_route
  accepts_nested_attributes_for :site_entries, allow_destroy: true, reject_if: :all_blank
  has_and_belongs_to_many :assigned_vehicles, class_name: "Vehicle"

  before_save :squish_name
  after_discard :nullify_default_driving_routes
  after_discard :clear_assigned_vehicles

  private
    def nullify_default_driving_routes
      vehicles.update_all(default_driving_route_id: nil)
    end

    def clear_assigned_vehicles
      assigned_vehicles.clear
    end

    def squish_name
      self.name&.squish!
    end
end
