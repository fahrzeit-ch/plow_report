class CustomerPolicy < ApplicationPolicy

  def index?
    true
  end

  def new?
    company_admin_or_owner?(record.client_of)
  end

  def create?
    company_admin_or_owner?(record.client_of)
  end

  def show?
    company_member?(record.client_of)
  end

  def update?
    company_admin_or_owner?(record.client_of)
  end

  def destroy?
    company_admin_or_owner?(record.client_of)
  end


  class Scope < Scope
    def resolve
      scope
    end
  end

end
