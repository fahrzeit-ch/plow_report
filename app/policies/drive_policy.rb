# frozen_string_literal: true

class DrivePolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    true
  end

  def create?
    own_record? || company_admin_or_owner?(record_company) || is_demo(record_company)
  end

  def show?
    own_record? || company_member?(record_company) || is_demo(record_company)
  end

  def update?
    own_record? || company_admin_or_owner?(record_company) || is_demo(record_company)
  end

  def destroy?
    own_record? || company_admin_or_owner?(record_company) || is_demo(record_company)
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
      [:app_drive_id, :start, :end, :distance_km, :tour_id, :vehicle_id, :associated_to_as_json, activity_execution_attributes: [:activity_id, :value]]
    when :api_create
      [:app_drive_id, :driver_id, :start, :end, :company_id, :site_id, :tour_id, :vehicle_id, :customer_id, :distance_km, :updated_at, :discarded_at, :created_at, activity: [:activity_id, :value]]
    when :api_update
      [:app_drive_id, :driver_id, :start, :end, :site_id, :tour_id, :vehicle_id, :customer_id, :distance_km, :updated_at, :discarded_at, activity: [:activity_id, :value]]
    end
  end


  class Scope < Scope
    def resolve
      scope
    end
  end

  private
    def record_company
      record.driver.company
    end

    def own_record?
      record.driver.user == user
    end
end
