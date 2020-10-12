class TourPolicy < ApplicationPolicy

  def index?
    true
  end

  def new?
    true
  end

  def create?
    own_record? || company_admin_or_owner?(company) || is_demo(company)
  end

  def show?
    own_record? || company_member?(company)
  end

  def update?
    own_record? || company_admin_or_owner?(company) || is_demo(company)
  end

  def destroy?
    own_record? || company_admin_or_owner?(company) || is_demo(company)
  end

  # Scopes:
  # :default
  # :api_create
  # :api_update
  def permitted_attributes(scope = :default)
    case scope
    when :default
      [:start_time, :end_time]
    when :api_create
      [:id, :driver_id, :start_time, :end_time, :created_at, :updated_at, :discarded_at]
    when :api_update
      [:driver_id, :start_time, :end_time, :updated_at, :discarded_at]
    end
  end


  class Scope < Scope
    def resolve
      scope
    end
  end

  private

  def company
    record.driver.company
  end

  def own_record?
    record.driver.user == user
  end

end
