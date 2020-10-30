# frozen_string_literal: true

class Company
  class RegistrationPolicy < ApplicationPolicy
    def create?
      true
    end
  end
end
