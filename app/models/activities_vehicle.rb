# frozen_string_literal: true

class ActivitiesVehicle < ApplicationRecord
  belongs_to :vehicle
  belongs_to :activity
end
