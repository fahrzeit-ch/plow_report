class Company
  class Settings
    attr_accessor :drive_options

    def initialize(attributes=nil)
      attributes ||= {}
      attributes.symbolize_keys!
      self.drive_options = DriveOptions.new(attributes[:drive_options])
    end

    class Type < ActiveRecord::Type::Value
      def type
        :jsonb
      end

      def cast(value)
        Settings.new(value)
      end

      def serialize(value)
        ::ActiveSupport::JSON.encode(value)
      end

      def deserialize(value)
        if String === value
          decoded = ::ActiveSupport::JSON.decode(value) rescue nil
          Settings.new(decoded)
        else
          super
        end
      end
    end
  end
end