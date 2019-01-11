class SitePolicy < ApplicationPolicy

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
    @company ||= record.customer.try(:client_of)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end

end
