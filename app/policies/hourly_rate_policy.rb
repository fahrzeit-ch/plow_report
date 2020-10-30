# frozen_string_literal: true

class HourlyRatePolicy < ApplicationPolicy
  def new?
    company_admin_or_owner?(company)
  end

  def create?
    company_admin_or_owner?(company)
  end

  def show?
    company_admin_or_owner?(company) || is_demo(company)
  end

  def update?
    company_admin_or_owner?(company)
  end

  def destroy?
    company_admin_or_owner?(company)
  end

  def deactivate?
    company_admin_or_owner?(company)
  end

  def activate?
    company_admin_or_owner?(company)
  end

  def company
    @company ||= record.company
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
