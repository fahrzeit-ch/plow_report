# frozen_string_literal: true

module Api
  module SpecHelpers
    # Wraps a Rspec response object in order to get an easy way to
    # match json data.
    class Response
      def initialize(response)
        @response = response
      end

      def parsed_response
        return @parsed_response unless @parsed_response.blank?

        raise "Response could not be parsed because it has empty body" if @response.body.empty?

        parsed = JSON.parse(@response.body)
        raise "Response is not valid json" unless parsed.is_a? Hash

        @parsed_response = parsed.with_indifferent_access
      end

      def attributes
        parsed_response
      end

      def has_attribute_keys?(*attrs)
        key_missing = false
        attrs.each { |key| key_missing = true unless attributes.key?(key) }
        !key_missing
      end

      def has_attribute_values?(attrs)
        attrs = attrs.with_indifferent_access
        attrs == attributes.select { |key| attrs.key?(key) }
      end

      def has_pagination?
        has_attribute_keys? :current_page, :next_page, :prev_page
      end

      def first_page?
        has_attribute_values?(current_page: current_page, prev_page: nil)
      end

      def is_page?(page)
        has_attribute_values?(current_page: page)
      end

      def missing_attributes(attrs)
        attrs = attrs.with_indifferent_access
        missing_keys = attrs.reject { |key| attributes.key?(key) }
        different_values = attrs.reject { |key| attributes[key] == attrs[key] }
        { missing: missing_keys, different_values: different_values }
      end

      def errors
        parsed_response[:errors]
      end

      def error?
        !errors.blank?
      end

      def inspect
        parsed_response.inspect
      end
    end
  end
end
