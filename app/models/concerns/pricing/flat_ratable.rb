# frozen_string_literal: true

module Pricing::FlatRatable
  TYPE_MAP = {
    activity_fee: Pricing::FlatRate::ACTIVITY_FEE,
    travel_expense: Pricing::FlatRate::TRAVEL_EXPENSE,
    commitment_fee: Pricing::FlatRate::COMMITMENT_FEE }

  extend ActiveSupport::Concern

  included do
    has_many :flat_rates, class_name: "Pricing::FlatRate", as: :flat_ratable, dependent: :destroy, autosave: true
    after_save :write_changed_rates
  end

  class_methods do
    def flat_rate(type)
      self.attribute type
      self.has_many type.to_s.pluralize.to_sym, -> { where(rate_type: TYPE_MAP[type]) }, class_name: "Pricing::FlatRate", as: :flat_ratable

      self.define_method type do
        current_or_new(type)
      end

      self.define_method "#{type}_attributes=" do |attrs|
        update_or_create_by_valid_from(attrs, type)
      end
    end
  end

  def changed_rates
    @changes ||= []
  end

  def update_or_create_by_valid_from(attrs, attribute_name)
    attrs.delete(:id) # id must not be used, update or create is decided based on valid_from date
    valid_from = attrs[:valid_from]
    attrs[:price] ||= Money.new("0.0")
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

  protected
    def write_changed_rates
      changed_rates.each(&:save)
    end
end
