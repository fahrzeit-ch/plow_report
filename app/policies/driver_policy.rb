class DriverPolicy < ApplicationPolicy

  def show?
    create?
  end

  def update?
    create?
  end

  def create?
    return true if record.company.nil?
    user.companies_for_role([CompanyMember::ADMINISTRATOR, CompanyMember::OWNER]).exists? record.company.id
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
