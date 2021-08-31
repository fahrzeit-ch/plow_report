# A vehicle can be assigned to a drive. For each vehicle, multiple activities can be assigned.
# This helps to scope the available activities in the app to only those for the selected vehicle.
# Additionally, vehicles can later have different prices assigned for the same activities
class Vehicle < ApplicationRecord
  include Discard::Model
  include ChangedSince
  include Pricing::HourlyRatable

  validates :name, presence: true, length: { maximum: 50 }
  validates_uniqueness_of :name, scope: [:company_id, :discarded_at], unless: :discarded?
  belongs_to :company

  has_many :vehicle_activity_assignments, dependent: :destroy
  has_many :activities, through: :vehicle_activity_assignments
  has_many :tours

  belongs_to :default_driving_route, optional: true, class_name: "DrivingRoute", inverse_of: :vehicles

  accepts_nested_attributes_for :vehicle_activity_assignments, reject_if: :all_blank, allow_destroy: true
  before_save :set_company_on_activities
  before_save :squish_name

  def activity_ids
    vehicle_activity_assignments.pluck(:activity_id)
  end

  def pricing_default_valid_from
    Season.current.start_date
  end

  def display_name
    return name unless discarded?
    "#{name} #{I18n.t('activerecord.attributes.vehicle.discarded_postfix')}"
  end

  private
    # Make sure, all activities have the company id set.
    def set_company_on_activities
      activities.each { |a| a.company_id = company_id unless a.persisted? }
    end

    def squish_name
      self.name&.squish!
    end
end
