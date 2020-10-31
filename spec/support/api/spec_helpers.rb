# frozen_string_literal: true

module Api
  module SpecHelpers
    def api_response
      ::Api::SpecHelpers::Response.new(response)
    end

    def stub_jwt_access_token
      token = instance_double("JWTToken")
      allow(JWTToken).to receive(:new).and_return(token)
      allow(token).to receive(:payload).and_return({ "user" => { "id" => "NR-5", "email" => "hans@muster.ch" } })
    end

    def sign_in_user(user)
      token = double acceptable?: true
      allow(controller).to receive(:doorkeeper_token) { token }
      allow_any_instance_of(Api::V1::ApiController).to receive(:current_resource_owner).and_return(user)
    end

    def parsed_response
      api_response.parsed_response
    end

    def has_attribute_values?(actual, expected)
      expected = expected.with_indifferent_access
      expected == actual.select { |key| expected.key?(key) }
    end
  end
end
