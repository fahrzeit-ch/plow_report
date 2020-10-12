class StandbyDate
  class DateRangePolicy < ApplicationPolicy
    def create?
      own_record? || company_admin_or_owner?(company) || is_demo(company)
    end

    private

    def company
      @company ||= Driver.find(record.driver_id).company
    end

    def own_record?
      user.drivers.exists? record.driver_id
    end
  end
end