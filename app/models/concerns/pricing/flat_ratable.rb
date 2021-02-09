# frozen_string_literal: true

module Pricing::FlatRatable
  extend ActiveSupport::Concern

  included do
    has_many :flat_rates, class_name: "Pricing::FlatRate", as: :flat_ratable, dependent: :destroy, autosave: true
    after_save :write_changed_rates
  end

  class_methods do
    def flat_rate(type, opts = {})
      self.attribute type
      self.has_many type.to_s.pluralize.to_sym, -> { where(rate_type: type) }, class_name: "Pricing::FlatRate", as: :flat_ratable

      self.define_method type do
        current_or_new(type, opts[:defaults])
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
    attrs[:rate_type] = attribute_name
    existing_rate = public_send(attribute_name.to_s.pluralize).where(valid_from: valid_from).first

    if existing_rate
      existing_rate.assign_attributes attrs
      public_send("#{attribute_name}_will_change!") if existing_rate.changed?
      changed_rates.push(existing_rate)
    else
      flat_rates.build attrs
    end
  end

  def current_or_new(attribute_name, defaults)
    relation = attribute_name.to_s.pluralize
    defaults ||= {}
    public_send(relation).current || public_send(relation).build(defaults.merge(rate_type: attribute_name))
  end

  protected
    def write_changed_rates
      changed_rates.each(&:save)
    end
end
