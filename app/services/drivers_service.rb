# frozen_string_literal: true

class DriversService

  def self.driver_scope(user)
    full_permitted_companies = user.companies_for_role([CompanyMember::ADMINISTRATOR, CompanyMember::OWNER, CompanyMember::DEMO_ACCOUNT]).select(:id)
    own_drivers = user.drivers.select(:id)

    Driver.where(id: own_drivers).or(Driver.where(company_id: full_permitted_companies))
  end

  def drivers_for(user, company)
    if company.nil?
      user.drivers
    else
      role = CompanyMember.role_of(user, company)
      case role
      when role.nil?
        Driver.none
      when CompanyMember::OWNER
        Driver.where(company_id: company.id)
      when CompanyMember::ADMINISTRATOR
        Driver.where(company_id: company.id)
      when CompanyMember::DEMO_ACCOUNT
        Driver.where(company_id: company.id)
      when CompanyMember::DRIVER
        Driver.where(company_id: company.id).joins(:driver_login).where(driver_logins: { user_id: user.id })
      else
        Driver.none
      end
    end
  end
end
