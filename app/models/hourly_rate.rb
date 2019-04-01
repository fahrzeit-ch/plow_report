# Defines the hourly rate used for price calculation of
# drives.
#
# Multiple Hourly Rates can be configured per company, the most specific will apply.
class HourlyRate < ApplicationRecord
  belongs_to :company, optional: false

  # When the activity is specified, the price rate will only apply to drives with the given activity
  belongs_to :activity, optional: true

  # When customer is specified, the rate will only apply to drives for that customer.
  belongs_to :customer, optional: true

  scope :overlapping, -> (other) { where('(valid_from, valid_until) OVERLAPS (?, ?)', other.valid_from, other.valid_until) }
  scope :same_scope, -> (other) { where(customer: other.customer, activity: other.activity, company: other.company).where.not(id: other.id) }

  monetize :price_cents
  audited

  validates :company, presence: true
  validate :uniqueness_of_scope

  private

  def uniqueness_of_scope
    return unless self.class.same_scope(self).overlapping(self).exists?
    self.errors.add(:base, :already_exists_in_time_range)
  end
end
