# frozen_string_literal: true

class Pricing::FlatRate < ApplicationRecord
  TRAVEL_EXPENSE = "travel_expense"
  ACTIVITY_FEE = "activity_fee"
  COMMITMENT_FEE = "commitment_fee"
  CUSTOM_FEE = "custom"

  TYPES = [TRAVEL_EXPENSE, ACTIVITY_FEE, COMMITMENT_FEE, CUSTOM_FEE]

  include Pricing::Price
  belongs_to :flat_ratable, polymorphic: true

end
