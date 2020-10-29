# frozen_string_literal: true

class CompanyMemberPolicy < ApplicationPolicy
  def show?
    create?
  end

  def update?
    create?
  end

  def create?
    for_company = record.company
    user.companies_for_role([CompanyMember::ADMINISTRATOR, CompanyMember::OWNER]).exists? for_company.id
  end

  def invite?
    create?
  end

  def resend_invitation?
    create?
  end

  def destroy?
    create?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
