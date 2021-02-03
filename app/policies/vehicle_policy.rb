# frozen_string_literal: true

class VehiclePolicy < ApplicationPolicy

  def create?
    company_admin_or_owner?(record.company) || is_demo(record.company)
  end

  def new?
    company_admin_or_owner? || is_demo(record.company)
  end

  def update?
    company_admin_or_owner?(record.company) || is_demo(record.company)
  end

  def destroy?
    company_admin_or_owner?(record.company) || is_demo(record.company)
  end

  def permitted_attributes
    [:name, hourly_rate_attributes: [:price, :valid_from],
            vehicle_activity_assignments_attributes: [:id,
                                                      :_destroy,
                                                      :activity_id,
                                                      hourly_rate_attributes: [:price, :valid_from],
                                                      activities_attributes: [:_destroy, :id, :name, :has_value, :value_label]]]
  end

  class Scope < Scope
    def resolve
      scope.where(company_id: auth_context.company)
    end
  end

end
