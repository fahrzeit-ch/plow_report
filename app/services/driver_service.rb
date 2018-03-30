class AssignmentError < StandardError
end

class DriverService

  # @param [User] auth_context
  def initialize(auth_context)
    @auth_context = auth_context
  end

  # Creates a new driver for the given company. The driver
  # will not be assigned to a user.
  # @param [Company] company
  # @param [Hash | Params] driver_params
  # @return [Driver]
  def create_company_driver(company, driver_params)
    company.drivers.create driver_params
  end

  # Add a user as driver to the company. if transfer_private is set, the
  # default driver will be assigned to the company (if exists). Otherwise
  # a new driver for the user will be created and assigned to the company
  #
  # @param [Company] company
  # @param [User] user
  # @param [Boolean] transfer_private
  # @raise [AssignmentError] Raises error if the user already has a driver assigned to the company
  def add_driver(company, user, transfer_private = false)
    if user.drivers.where(company_id: company.id).exists?
      raise AssignmentError.new I18n.t('errors.drivers.already_assigned')
    else
      driver = user.drivers.where(company_id: nil).first

      if driver && transfer_private
        driver.update_attribute(:company_id, company.id)
      else
        driver = Driver.create(name: user.name, company_id: company.id)
        user.drivers << driver
      end
      driver
    end
  end


end