# frozen_string_literal: true

module ChangedSince
  extend ActiveSupport::Concern

  included do
    scope :changed_since, -> (datetime) { where(
      arel_table[:created_at].gt(datetime)
          .or(arel_table[:updated_at].gt(datetime))
          .or(arel_table[:discarded_at].gt(datetime))) }
  end
end
