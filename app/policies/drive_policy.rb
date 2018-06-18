class DrivePolicy < ApplicationPolicy

  def index?
    true
  end

  def new?
    true
  end

  def create?
    own_record? || company_admin_or_owner?(record.driver.company)
  end

  def show?
    own_record? || company_member?(record.driver.company)
  end

  def update?
    own_record? || company_admin_or_owner?(record.driver.company)
  end

  def destroy?
    own_record? || company_admin_or_owner?(record.driver.company)
  end

  def finish?
    own_record?
  end


  class Scope < Scope
    def resolve
      scope
    end
  end

  private
  def own_record?
    record.driver.user == user
  end

end