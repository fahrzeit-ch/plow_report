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

  def available_drivers_for(standby_list)
    @available_drivers ||= current_company.drivers.to_a
    @available_drivers - standby_list.map(&:driver)
  end

  def all_drivers_selection_options(blank_value = I18n.t('common.all'))
    drivers = current_company.drivers.map do |d|
      [d.name, d.id]
    end
    [[blank_value, nil]] + drivers
  end

  def driver_selection_options(standby_list, blank_value = I18n.t('common.all'))
    drivers = available_drivers_for(standby_list).map do |u|
        [u.name, u.id]
    end
    [[blank_value, nil]] + drivers
  end
end