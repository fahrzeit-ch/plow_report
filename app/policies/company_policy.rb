# frozen_string_literal: true

class CompanyPolicy < ApplicationPolicy
  def show?
    company_member? record
  end

  def edit?
    company_admin_or_owner? record
  end

  def update?
    user.owned_companies.exists?(id: record.id)
  end

  def destroy?
    update?
  end

  def index_drives?
    company_member? record
  end

  def index_drivers?
    company_admin_or_owner?(record) || is_demo(record)
  end

  def index_members?
    company_admin_or_owner?(record) || is_demo(record)
  end

  def index_sites?
    company_admin_or_owner?(record) || is_demo(record)
  end

  def index_tours?
    company_member?(record) || is_demo(record)
  end

  def index_activities?
    company_admin_or_owner?(record) || is_demo(record)
  end

  def index_standby_dates?
    company_member?(record)
  end

  def index_customers?
    company_member? record
  end

  def index_hourly_rates?
    company_admin_or_owner?(record) || is_demo(record)
  end

  def index_vehicles?
    company_admin_or_owner?(record) || is_demo(record)
  end

  def index_routes?
    company_admin_or_owner?(record) || is_demo(record)
  end

  def index_reports?
    company_admin_or_owner?(record) || is_demo(record)
  end

  def create?
    true
  end

  class Scope < Scope
    def resolve
    end
  end
end
