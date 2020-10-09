class DriversService

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
      when CompanyMember::DRIVER
        Driver.where(company_id: company.id).joins(:driver_login).where(driver_logins: { user_id: user.id})
      else
        Driver.none
      end
    end
  end

end