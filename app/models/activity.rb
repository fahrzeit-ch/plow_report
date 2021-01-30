# frozen_string_literal: true

# Describes a possible activity that can be selected when
# creating a drive.
#
# ## Activity Scopes
# An activity is created and visible within a company. Activities
# without a company assigned are available globally and
# visible for personal that have no company assigned
#
# ## Values
# If `has_value` is set, it is expected that executions of this
# activities have a value defined.
#
# An example would be an activity like "Refill Salt", which expects
# the driver to enter value for the amount of salt he refilled.
#
# `value_label` will be shown to users next to the value input.
#
# ## Activity Name
# The name of the activity is visible to the user and must be unique
# within a company.
class Activity < ApplicationRecord
  belongs_to :company, optional: true

  has_many :vehicle_activity_assignments, dependent: :destroy
  has_many :vehicles, through: :vehicle_activity_assignments

  has_many :activity_executions, dependent: :restrict_with_exception

  scope :default, -> { where(company: nil) }

  validates :name, presence: true, uniqueness: { scope: :company_id }
  before_save :squish_name

  audited

  # Create a clone of this activity for the given company
  # This will raise an error if validation fails.
  def clone_to!(company)
    copy = dup
    copy.company = company
    copy.save!
    copy
  end

  # Returns true if self is equal for all attributes except for company
  # @param [Activity] other
  def same?(other)
    has_value? == other.has_value? && name == other.name && value_label == other.value_label
  end

  private
    def squish_name
      self.name&.squish!
    end
end
