# frozen_string_literal: true

class DrivingRoutePolicy < ApplicationPolicy
  def new?
    company_admin_or_owner?(company)
  end

  def create?
    company_admin_or_owner?(company)
  end

  def show?
    company_member?(company)
  end

  def update?
    company_admin_or_owner?(company)
  end

  def destroy?
    company_admin_or_owner?(company)
  end

  def company
    @company ||= record.try(:company)
  end

  def permitted_attributes
    [:name, :site_ordering, site_entries_attributes: [:id, :_destroy, :site_id, :position]]
  end

  class Scope < Scope
    def resolve
      scope.where(company: auth_context.company)
    end
  end
end
