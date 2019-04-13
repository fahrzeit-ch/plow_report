# Defines the hourly rate for a combination of company, activity and customer.
#
# The source is either an explicit match of an +HourlyRate+ with the same combination of
# company, activity and customer or the best closest inherited HourlyRate.
# The lookup follows this hierarchy:
#
#   1. customer_activity_rate (Activity and Customer set)
#   2. customer_base_rate (only Customer set)
#   3. activity_rate (only Activity set)
#   4. base_rate (none of them set)
#
# This model is baked by a database view and therefore is readonly.
#
class ImplicitHourlyRate < ApplicationRecord

  belongs_to :inherited_from, foreign_key: :hourly_rate_id, class_name: 'HourlyRate'
  belongs_to :activity
  belongs_to :customer
  monetize :price_cents

  delegate :valid_from, :valid_until, to: :inherited_from

  def inherited?
    inheritance_level > 0
  end

  def to_explicit_rate
    HourlyRate.new(price: price,
                   activity_id: activity_id,
                   company_id: company_id,
                   valid_from: valid_from,
                   valid_until: valid_until,
                   customer_id: customer_id)
  end

  def find(*args)
    raise
  end

  def readonly?
    true
  end
end