class CompanyPolicy < ApplicationPolicy

  def show?
    user.companies.exists?(id: record.id)
  end

  def update?
    user.owned_companies.exists?(id: record.id)
  end

  def destroy?
    update?
  end

  def create?
    true
  end

  class Scope < Scope
    def resolve

    end
  end
end
