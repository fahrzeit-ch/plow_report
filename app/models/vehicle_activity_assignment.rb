# frozen_string_literal: true

class VehicleActivityAssignment < ApplicationRecord
  include Pricing::HourlyRatable

  belongs_to :vehicle
  belongs_to :activity

  accepts_nested_attributes_for :activity, reject_if: :all_blank, allow_destroy: false
  validates_uniqueness_of :activity_id, scope: :vehicle_id

  before_destroy :check_can_destroy

  def pricing_default_valid_from
    Season.current.start_date
  end

  def can_destroy?
    !Drive.joins(:activity_execution).where(activity_executions: {activity_id: activity_id }, vehicle: vehicle).any?
  end

  private
    def check_can_destroy
      unless can_destroy?
        errors.add :base, :dont_destroy_dependent_data
        throw :abort
      end
    end
end
