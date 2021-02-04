# frozen_string_literal: true

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

  def area?
    show?
  end

  def update?
    company_admin_or_owner?(company)
  end

  def destroy?
    company_admin_or_owner?(company)
  end

  def deactivate?
    company_admin_or_owner?(company)
  end

  def activate?
    company_admin_or_owner?(company)
  end

  def company
    @company ||= record.customer.try(:client_of)
  end

  def permitted_attributes
    [:display_name, :first_name, :name, :street, :nr, :zip, :city, :active, :area_features,
     site_activity_flat_rates_attributes: [:id, :_delete, :activity_id, activity_fee_attributes: [:active, :price, :valid_from]],
     commitment_fee_attributes: [:active, :price, :valid_from],
     travel_expense_attributes: [:active, :price, :valid_from]]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
