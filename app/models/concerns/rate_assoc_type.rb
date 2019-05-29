module RateAssocType
  CUSTOMER_ACTIVITY_RATE = 'customer_activity_rate'.freeze
  CUSTOMER_BASE_RATE = 'customer_base_rate'.freeze
  ACTIVITY_RATE = 'activity_rate'.freeze
  BASE_RATE = 'base_rate'.freeze

  # Returns the type of rate definition based on its associations. Those can be one
  # of the following:
  #
  #   1. customer_activity_rate (Activity and Customer set)
  #   2. customer_base_rate (only Customer set)
  #   3. activity_rate (only Activity set)
  #   4. base_rate (none of them set)
  #
  # @return [String] The type of rate association
  def rate_type
    case
    when activity_id && customer_id
      RateAssocType::CUSTOMER_ACTIVITY_RATE
    when customer_id && !activity_id
      RateAssocType::CUSTOMER_BASE_RATE
    when activity_id && !customer_id
      RateAssocType::ACTIVITY_RATE
    when !activity_id && !customer_id
      RateAssocType::BASE_RATE
    end
  end
end