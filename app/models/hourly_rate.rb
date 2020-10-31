# frozen_string_literal: true

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

  attribute :valid_from, :date, default: Date.new(2000, 1, 1)
  attribute :valid_until, :date, default: Date.new(2100, 1, 1)

  scope :active, -> { where("? BETWEEN valid_from AND valid_until", Time.current) }
  scope :overlapping, ->(other) { where("(valid_from, valid_until) OVERLAPS (?, ?)",
                                         other.valid_from, other.valid_until) }
  scope :same_scope, ->(other) { where(customer: other.customer, activity: other.activity,
                                        company: other.company).where.not(id: other.id) }

  include RateAssocType

  monetize :price_cents
  audited

  validates :company, presence: true
  validate :uniqueness_of_scope

  def base_rate?
    customer_id.nil? && activity_id.nil?
  end

  def destroy_children
    children.destroy_all
  end

  def destroy_self_and_children
    destroy_children
    destroy
  end

  def children
    return self.class.none unless base_rate?
    self.class.where(company: company).where.not(id: id)
  end

  class << self
    def base_rate
      find_by(customer_id: nil, activity_id: nil)
    end

    def activity_rates
      where(customer_id: nil).where.not(activity_id: nil)
    end
  end

  private
    def uniqueness_of_scope
      return unless self.class.same_scope(self).overlapping(self).exists?
      self.errors.add(:base, :already_exists_in_time_range)
    end
end
