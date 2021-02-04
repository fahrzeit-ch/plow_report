# frozen_string_literal: true

module Pricing::FlatRatable
  extend ActiveSupport::Concern

  included do
    has_many :flat_rates, class_name: "Pricing::FlatRate", as: :flat_ratable, dependent: :destroy, autosave: true
    has_many :activity_fees, -> { where(rate_type: Pricing::FlatRate::ACTIVITY_FEE) }, class_name: "Pricing::FlatRate", as: :flat_ratable
    has_many :travel_expenses, -> { where(rate_type: Pricing::FlatRate::TRAVEL_EXPENSE) }, class_name: "Pricing::FlatRate", as: :flat_ratable
    has_many :commitment_fees, -> { where(rate_type: Pricing::FlatRate::COMMITMENT_FEE) }, class_name: "Pricing::FlatRate", as: :flat_ratable

    after_save :write_changed_rates

    attribute :activity_fee
    attribute :travel_expense
    attribute :commitment_fee
  end

  def changed_rates
    @changes ||= []
  end

  def update_or_create_by_valid_from(attrs, attribute_name)
    attrs.delete(:id) # id must not be used, update or create is decided based on valid_from date
    valid_from = attrs[:valid_from]
    existing_rate = public_send(attribute_name.to_s.pluralize).where(valid_from: valid_from).first

    if existing_rate
      existing_rate.assign_attributes attrs
      public_send("#{attribute_name}_will_change!") if existing_rate.changed?
      changed_rates.push(existing_rate)
    else
      public_send(attribute_name.to_s.pluralize).build attrs
    end
  end

  def commitment_fee
    commitment_fee.current
  end

  def commitment_fee_attributes=(attrs)
    update_or_create_by_valid_from(attrs.merge(rate_type: Pricing::FlatRate::COMMITMENT_FEE), :commitment_fee)
  end

  def travel_expense
    travel_expenses.current
  end

  def travel_expense_attributes=(attrs)
    update_or_create_by_valid_from(attrs.merge(rate_type: Pricing::FlatRate::TRAVEL_EXPENSE), :travel_expense)
  end

  def activity_fee
    activity_fees.current
  end

  def activity_fee_attributes=(attrs)
    update_or_create_by_valid_from(attrs.merge(rate_type: Pricing::FlatRate::ACTIVITY_FEE), :activity_fee)
  end

  def write_changed_rates
    changed_rates.each(&:save)
  end
end
