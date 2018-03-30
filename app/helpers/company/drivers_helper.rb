module Company::DriversHelper

  def company_driver
    @driver || Driver.new
  end

  def company_driver_user_selection_options
    # Get users that are assigned as drivers on this company
    user_ids = DriverLogin.select(:user_id).joins(:driver)
                   .where(drivers: {company_id: current_company.id} )

    current_company.users.where.not(id: user_ids).map do |u|
      [u.name, u.id]
    end
  end

  def driver_selection_options
    drivers = current_company.drivers.map do |u|
        [u.name, u.id]
    end
    [[I18n.t('common.all'), nil]] + drivers
  end
end