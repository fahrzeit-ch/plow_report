# frozen_string_literal: true

class DriverPolicy < ApplicationPolicy
  def show?
    create?
  end

  def update?
    create?
  end

  def create?
    return true if record.company.nil?
    company_admin_or_owner?(record.company) || is_demo(record.company)
  end

  def destroy?
    create?
  end

  class Scope < Scope
    def resolve
      DriversService.driver_scope(user)
    end
  end
end
