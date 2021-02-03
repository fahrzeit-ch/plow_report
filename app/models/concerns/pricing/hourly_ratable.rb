# frozen_string_literal: true

module Pricing::HourlyRatable
  extend ActiveSupport::Concern

  included do
    has_many :hourly_rates, class_name: "Pricing::HourlyRate", as: :hourly_ratable, dependent: :destroy
    after_save :update_hourly_rate
  end

  def hourly_rate
    hourly_rates.current
  end

  def hourly_rate_attributes=(attrs)
    valid_from = attrs[:valid_from]
    @rate = hourly_rates.where(valid_from: valid_from).first
    if @rate
      @rate.assign_attributes attrs
    else
      hourly_rates.build attrs
    end
  end

  def update_hourly_rate
    @rate&.save
  end
end
