# frozen_string_literal: true

module Pricing::HourlyRatable
  extend ActiveSupport::Concern

  attr_internal :rate

  included do
    attribute :hourly_rate
    has_many :hourly_rates, class_name: "Pricing::HourlyRate", as: :hourly_ratable, dependent: :destroy, autosave: true
    after_save :update_hourly_rate
  end

  def hourly_rate
    hourly_rates.current || hourly_rates.build
  end

  def hourly_rate_attributes=(attrs)
    attrs.delete(:id) # id must not be used, update or create is decided based on valid_from date
    valid_from = attrs[:valid_from]
    @rate = hourly_rates.where(valid_from: valid_from).first
    if @rate
      # in this case, we need to manually save the updates using after_save callback
      @rate.assign_attributes attrs
      hourly_rate_will_change! if @rate.changed?
    else
      # in this case association autosave will kick in
      hourly_rates.build attrs
    end
  end

  def update_hourly_rate
    @rate&.save
  end
end
