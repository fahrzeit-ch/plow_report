# frozen_string_literal: true

class DriverApplicationPolicy < ApplicationPolicy
  def index?
    false
  end

  def create?
    true
  end

  def review?
    true
  end

  def show?
    record.user == user
  end

  def accept?
    company_admin_or_owner?(company)
  end

  def permitted_attributes_for_create
    [:recipient]
  end

  def permitted_attributes_for_accept
    [:assign_to_id]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end

  private
    def company
      record.accepted_to
    end
end
