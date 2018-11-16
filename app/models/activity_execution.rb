# Connects an Activity with a drive.
#
# An `ActivityExecution` requires the value
# attribute to be set if the related `Activity` has set
# the option `has_value`
class ActivityExecution < ApplicationRecord
  belongs_to :activity
  belongs_to :drive

  validates_presence_of :value, if: 'value_required?'

  private

  def value_required?
    activity.has_value?
  end
end
