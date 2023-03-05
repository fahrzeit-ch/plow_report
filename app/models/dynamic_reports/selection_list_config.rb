# frozen_string_literal: true

class DynamicReports::SelectionListConfig
  attr_accessor :source
  attr_accessor :display_member
  attr_accessor :value_member

  def initialize(attributes = nil)
    attributes ||= {}
    attributes.symbolize_keys!
    self.source = attributes[:source]
    self.display_member = attributes[:display_member]
    self.value_member = attributes[:value_member]
  end

  class Type < ActiveRecord::Type::Value
    def type
      :jsonb
    end

    def cast(value)
      DynamicReports::SelectionListConfig.new(value)
    end

    def serialize(value)
      ::ActiveSupport::JSON.encode(value)
    end

    def deserialize(value)
      if String === value
        decoded = ::ActiveSupport::JSON.decode(value) rescue nil
        DynamicReports::SelectionListConfig.new(decoded)
      else
        super
      end
    end
  end
end
