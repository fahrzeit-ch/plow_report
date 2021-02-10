# frozen_string_literal: true

class VehicleReassignment
  include ActiveModel::Model

  attr_accessor :activity_executions
  attr_accessor :tour_id, :new_vehicle_id
  validates :tour_id, :new_vehicle_id, presence: true
  validate :all_affected_reassigned

  def activity_replacements
    @activity_replacements ||= activity_executions.group(:activity_id).pluck(:activity_id).map do |id|
      ActivityReplacement.new(old_activity_id: id)
    end
  end

  def activity_replacements_attributes=(attrs)
    attrs.each do |k,v|
      replacement = activity_replacements.find { |r| r.old_activity_id == v[:old_activity_id].to_i }
      replacement.assign_attributes v if replacement
    end
  end

  def activity_executions
    return unless tour
    @activity_executions ||= ActivityExecution.where(activity_executions: { activity_id: missing_activities }, drive_id: tour.drives )
  end

  def tour
    Tour.find_by(id: tour_id)
  end

  def new_vehicle
    Vehicle.find_by(id: new_vehicle_id)
  end

  def save
    return unless activity_replacements.all? { |r| r.valid? }
    apply_activity_replacements
    if valid?
      Tour.transaction do
        activity_executions.each(&:save)
        tour.update_attribute(:vehicle_id, new_vehicle_id)
        tour.drives.each { |d| d.update_attribute(:vehicle_id, new_vehicle_id) }
      end
    end
  end

  private

    def load_activity_executions
      if tour_id && new_vehicle_id
        @activity_executions = affected
      end
    end

    def missing_activities
      return [] unless tour && new_vehicle
      prev = tour&.vehicle&.activities.pluck(:id)
      new = new_vehicle&.activities.pluck(:id)
      prev - new
    end

    def apply_activity_replacements
      activity_executions.each do |ae|
        replacement = activity_replacements.find { |r| r.old_activity_id = ae.activity_id }
        ae.activity_id = replacement.new_activity_id
      end
    end

    def all_affected_reassigned
      unless activity_executions.all? { |ae| ae.activity_id_changed? }
        errors.add(:activity_executions, :reassign_required)
      end
    end

end