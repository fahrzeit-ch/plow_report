# frozen_string_literal: true

class ReasonabilityCheckJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound

  I18N_SCOPE = "activerecord.errors.models.tour"

  def perform(tour_id)
    tour = Tour.find(tour_id)

    delete_existing(tour)
    warnings = []

    if tour.invalid_drives.any?
      warnings << "#{I18N_SCOPE}.drives.invalid"
    end

    unless tour.vehicle_id
      warnings << "#{I18N_SCOPE}.vehicle.required"
    end

    if tour.drives.empty?
      warnings << "#{I18N_SCOPE}.drives.empty"
    end

    if warnings.any?
      ReasonabilityCheckWarning.create record: tour, warnings: warnings
    end
  end

  def delete_existing(tour)
    ReasonabilityCheckWarning.delete_by(record: tour)
  end
end
