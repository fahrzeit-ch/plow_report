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
      full_permitted_companies = user.companies_for_role([CompanyMember::ADMINISTRATOR, CompanyMember::OWNER, CompanyMember::DEMO_ACCOUNT]).select(:id)
      own_drivers = user.drivers.select(:id)

      scope.where(id: own_drivers).or(Driver.where(company_id: full_permitted_companies))
    end
  end
end
