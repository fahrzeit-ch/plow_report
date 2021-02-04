# frozen_string_literal: true

module Pricing::FlatRatable
  TYPE_MAP = {
    activity_fee: Pricing::FlatRate::ACTIVITY_FEE,
    travel_expense: Pricing::FlatRate::TRAVEL_EXPENSE,
    commitment_fee: Pricing::FlatRate::COMMITMENT_FEE }

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
    attrs[:rate_type] = Pricing::FlatRatable::TYPE_MAP[attribute_name]
    existing_rate = public_send(attribute_name.to_s.pluralize).where(valid_from: valid_from).first

    if existing_rate
      existing_rate.assign_attributes attrs
      public_send("#{attribute_name}_will_change!") if existing_rate.changed?
      changed_rates.push(existing_rate)
    else
      flat_rates.build attrs
    end
  end

  def current_or_new(attribute_name)
    relation = attribute_name.to_s.pluralize
    public_send(relation).current || public_send(relation).build(rate_type: Pricing::FlatRatable::TYPE_MAP[attribute_name])
  end

  def commitment_fee
    commitment_fee.current
  end

  def commitment_fee_attributes=(attrs)
    update_or_create_by_valid_from(attrs, :commitment_fee)
  end

  def travel_expense
    travel_expenses.current
  end

  def travel_expense_attributes=(attrs)
    update_or_create_by_valid_from(attrs, :travel_expense)
  end

  def activity_fee
    activity_fees.current
  end

  def activity_fee_attributes=(attrs)
    update_or_create_by_valid_from(attrs, :activity_fee)
  end

  def write_changed_rates
    changed_rates.each(&:save)
  end
end
