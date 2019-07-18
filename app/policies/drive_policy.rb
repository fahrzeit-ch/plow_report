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

  # Scopes:
  # :default
  # :api_create
  # :api_update
  def permitted_attributes(scope = :default)
    case scope
    when :default
      [:start, :end, :distance_km, :associated_to_as_json, activity_execution_attributes: [:activity_id, :value]]
    when :api_create
      [:driver_id, :start, :end, :company_id, :site_id, :distance_km, :created_at, activity: [:activity_id, :value]]
    end
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
