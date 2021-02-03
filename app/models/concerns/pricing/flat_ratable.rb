# frozen_string_literal: true

module Pricing::FlatRatable
  extend ActiveSupport::Concern

  included do
    has_many :flat_rates, class_name: "Pricing::FlatRate", as: :flat_ratable, dependent: :destroy
    has_many :activity_fees, -> { where(rate_type: Pricing::FlatRate::ACTIVITY_FEE) }, class_name: "Pricing::FlatRate", as: :flat_ratable
    has_many :travel_expenses, -> { where(rate_type: Pricing::FlatRate::TRAVEL_EXPENSE) }, class_name: "Pricing::FlatRate", as: :flat_ratable
    has_many :commitment_fees, -> { where(rate_type: Pricing::FlatRate::COMMITMENT_FEE) }, class_name: "Pricing::FlatRate", as: :flat_ratable
  end
end
