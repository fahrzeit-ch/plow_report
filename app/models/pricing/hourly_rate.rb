# frozen_string_literal: true

class Pricing::HourlyRate < ApplicationRecord
  belongs_to :hourly_ratable, polymorphic: true
  include Pricing::Price
end
