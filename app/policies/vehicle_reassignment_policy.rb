# frozen_string_literal: true

class VehicleReassignmentPolicy < ApplicationPolicy
  def prepare?
    company_admin_or_owner?(company)
  end

  def create?
    company_admin_or_owner?(company)
  end

  def permitted_attributes
    [:tour_id, :new_vehicle_id, activity_replacements_attributes: [:old_activity_id, :new_activity_id]]
  end


  class Scope < Scope
    def resolve
      scope
    end
  end

  private
    def company
      record.tour.driver.company
    end
end
