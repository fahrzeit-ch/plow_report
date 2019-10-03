class DriversService

  def drivers_for(user, company)
    if company.nil?
      user.drivers
    else
      role = CompanyMember.role_of(user, company)
      case role
      when role.nil?
        []
      when CompanyMember::OWNER
        company.drivers
      when CompanyMember::ADMINISTRATOR
        company.drivers
      when CompanyMember::DRIVER
        company.drivers.joins(:driver_login).where(driver_logins: { user_id: user.id})
      else
        []
      end
    end
  end

end