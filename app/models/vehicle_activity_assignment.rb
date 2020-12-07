# frozen_string_literal: true

class VehicleActivityAssignment < ApplicationRecord
  belongs_to :vehicle
  belongs_to :activity

  accepts_nested_attributes_for :activity, reject_if: :all_blank
end
