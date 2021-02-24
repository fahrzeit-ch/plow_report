# frozen_string_literal: true

# Connects an Activity with a drive.
#
# An `ActivityExecution` requires the value
# attribute to be set if the related `Activity` has set
# the option `has_value`
class ActivityExecution < ApplicationRecord
  belongs_to :activity
  belongs_to :drive, touch: true

  validates_presence_of :value, if: :value_required?

  audited

  # Moves this execution to a corresponding activity on the given company
  # @raise [StandardError] When no matching activity could be found and activity could not cloned to the target company
  # @param [Company] company
  def move_to(company)
    raise StandardError, "company must be persisted to assign activity executions to" unless company.persisted?
    target_activity = company.activities.find_by(name: activity.name)
    target_activity = activity.clone_to!(company) if target_activity.nil?
    if target_activity.same? activity
      update(activity: target_activity)
    else
      raise StandardError, "Unable to find or create a matching activity for the given company"
    end
  rescue ActiveRecord::RecordInvalid => e
    raise StandardError, "Unable to clone activity to the target company: #{e.message}"
  end

  private
    def value_required?
      activity.try(:has_value)
    end
end
