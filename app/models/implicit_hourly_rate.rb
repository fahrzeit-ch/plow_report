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
# ==Example
#
#   # Assuming you have a company wide base_rate and one for a customer
#   # (Note that we omit the customer_id for all our example code for readability reasons)
#   base_rate = HourlyRate.create(price: '12.5')
#   customer_specific_rate = HourlyRate.create(price: '18', customer: my_special_customer)
#
#   # Now we can grab implicit rates for specific customer/activity combinations:
#
#   # This will return inherited hourly rates all referencing the base_rate
#   hourly_rates = ImplicitHourlyRate.where(customer: other_customer, activity_id: plowing.id)
#
#
#
# This model is baked by a database view and therefore is readonly.
#
class ImplicitHourlyRate < ApplicationRecord

  belongs_to :inherited_from, foreign_key: :hourly_rate_id, class_name: 'HourlyRate'
  belongs_to :activity
  belongs_to :customer
  monetize :price_cents

  # Inform pundit policy resolver to use +HourlyRatePolicy+.
  def self.policy_class
    HourlyRatePolicy
  end

  delegate :valid_from, :valid_until, to: :inherited_from

  # Whether or not the price for this customer/activity combination was defined explicitly
  # or is retrieved by inheritance from an higher level +HourlyRate+
  #
  # @return [TrueClass|FalseClass] returns true for inherited hourly rates or false
  #                                if the the rate was defined explicitly.
  def inherited?
    inheritance_level > 0
  end

  # Builds a
  def to_explicit_rate
    HourlyRate.new(price: price,
                   activity_id: activity_id,
                   company_id: company_id,
                   valid_from: valid_from,
                   valid_until: valid_until,
                   customer_id: customer_id)
  end

  # Make this ApplicationRecord readonly in order to prevent ActiveRecord from trying
  # to write to the Database View.
  def readonly?
    true
  end


  def self.activity_rates
    items = where(customer_id: nil)
    best_matches(items)
  end

  def self.customer_rates
    items = where.not(customer_id: nil)
    best_matches(items)
  end


  # Applies a best match filter to the given list. The algorithm works like this:
  #
  # 1. Groups items with the same target (meaning same customer_id/activity_id combinations)
  # 2. Map the +ImplicitHourlyRate+ with the lowest +inheritance_level+ within its group to new array
  #
  # When you retrieve ImplicitHourlyRates you usually get a result for each inheritance_level, if there
  # is one specified.
  #
  # ==Example
  # This may return base_rate, activity_base_rate and the customer_base_rate.
  #
  #   customer_rates = ImplicitHourlyRates.where(customer_id: 12, activity_id: 3)
  #   applicable_rates = ImplicitHourlyRates.best_matches(customer_rates)
  #
  # @param [Enumerable] list, A list of ImplicitHourlyRates that.
  # @return [Array] Array with hourly rates having lowest inheritance_level for their target
  def self.best_matches(list)
    raise ArgumentError, 'Can not apply best matches to nil. Please provide an enumerable' if list.nil?

    # Groups rates with same customer & activity ids
    # customer_id may be nil.
    grouping_fnc = -> (hr) { [hr.customer_id, hr.activity_id] }

    list
        .group_by(&grouping_fnc)
        .map do |pr_group|
          # select the rate with the lowest inheritance level
          # which means it is the most accurate value for the customer_id and activity_id
          # combination.
          pr_group[1].min_by(&:inheritance_level)
        end
  end

end