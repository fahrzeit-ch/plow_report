# frozen_string_literal: true

class VehicleActivityAssignment < ApplicationRecord
  include Pricing::HourlyRatable

  belongs_to :vehicle
  belongs_to :activity

  accepts_nested_attributes_for :activity, reject_if: :all_blank

  def pricing_default_valid_from
    Season.current.start_date
  end
end
