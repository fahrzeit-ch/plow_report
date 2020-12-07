# frozen_string_literal: true

class ActivityPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    auth_context.company_admin_or_owner?
  end

  def create?
    company_admin_or_owner?(record.company)
  end

  def show?
    company_member?(record.company)
  end

  def update?
    company_admin_or_owner?(record.company)
  end

  def destroy?
    company_admin_or_owner?(record.company)
  end

  def permitted_attributes
    [:name, :has_value, :value_label]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
