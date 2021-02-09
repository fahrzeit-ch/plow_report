# frozen_string_literal: true

module Pricing::Price
  extend ActiveSupport::Concern
  included do
    monetize :price_cents
    validates :valid_from, presence: true, date: true
    after_initialize :set_default_valid_from

    def self.for_date(i)
      valid_from_col = self.arel_table[:valid_from]
      where(valid_from_col.lt(i)).order(valid_from: :desc).first
    end

    def self.current
      for_date(DateTime.current)
    end

  end

  def set_default_valid_from
    self.valid_from ||= self.try(:pricing_default_valid_from) || DateTime.current
  end
end
