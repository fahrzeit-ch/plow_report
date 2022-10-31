# frozen_string_literal: true

class AppLoginPolicy < ApplicationPolicy
  def new?
    auth_context.company_admin_or_owner?
  end

  def create?
    auth_context.company_admin_or_owner?
  end

  def show?
    company_admin_or_owner?(record.company)
  end

  def reset_password?
    company_admin_or_owner?(record.company)
  end

  def destroy?
    company_admin_or_owner?(record.company)
  end

  def permitted_attributes
    [:name, :has_value, :value_label]
  end

end
