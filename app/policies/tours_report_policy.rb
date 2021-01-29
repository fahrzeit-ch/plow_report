# frozen_string_literal: true

class ToursReportPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    company_admin_or_owner?(company) || is_demo(company)
  end

  def create?
    new?
  end

  def show?
    new?
  end

  def update?
    false
  end

  def destroy?
    new?
  end

  # Scopes:
  # :default
  # :api_create
  # :api_update
  def permitted_attributes
    [:start_date, :end_date]
  end


  class Scope < Scope
    def resolve
      scope
    end
  end

  private
    def company
      record.company
    end
end