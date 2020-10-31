# frozen_string_literal: true

module Api
  module SpecHelpers
    class Resource
      attr_reader :response
      attr_accessor :resource_data

      # @param [Response] response
      # @param [Hash] resource_data
      def initialize(response, resource_data)
        @response = response
        @resource_data = resource_data
      end



      # returns true if the attributes for this resource is included in the response.
      def included?
        !@response.get_included(id, type).nil?
      end

      def attributes
        @resource_data[:attributes]
      end

      def id
        @resource_data[:id]
      end
    end
  end
end
