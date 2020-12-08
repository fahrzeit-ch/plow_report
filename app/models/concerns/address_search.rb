# frozen_string_literal: true

module AddressSearch
  extend ActiveSupport::Concern

  included do
    def self.search(q)
      if q.blank?
        self.all
      else
        where(concat_search_columns.matches("%#{q}%"))
      end
    end

    def self.concat_search_columns
      arel_table[:name]
        .concat(arel_table[:first_name])
        .concat(arel_table[:street])
        .concat(arel_table[:city])
    end

  end
end

