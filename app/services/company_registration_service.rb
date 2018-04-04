# Service class in order to create, create/setup a new company.
class CompanyRegistrationService

  # @param [DriverService] driver_service
  def initialize(driver_service)
    @driver_service = driver_service
  end

  # Takes a Company::Registration object and creates
  # the company. It returns a Company::RegistrationResult providing
  # data about the successful/unsuccessful steps
  def create(registration)
    result = Company::RegistrationResult.new
    result.registration = registration
    company = Company.new(name: registration.name, contact_email: registration.contact_email)

    Company.transaction do |t|
      # Create company
      result.company = company

      unless company.save
        # copy validation errors to registration model and return
        registration.errors.copy!(company.errors)
        # registration.errors = company.errors
        result.has_errors = true
        return result
      end

      # Add owner as company member if this process fails, we it will fail the transaction
      member = company.add_member registration.owner, CompanyMember::OWNER
      unless member.persisted?
        registration.errors.add(:base, :unable_to_add_member)
        result.has_errors = true
        raise ActiveRecord::Rollback, 'Call tech support!'
      end

    end

    process_driver_setup(registration, company, result)
    result
  end

  private

  # @param [Company::Registration] registration
  # @param [Company] company
  # @param [Company::RegistrationResult] result
  # @return [Company::RegistrationResult]
  def process_driver_setup(registration, company, result)
    if registration.add_owner_as_driver
      driver_result = @driver_service.add_driver(company, registration.owner, registration.transfer_private_drives)
      result.driver_created = driver_result[:action] == :created
      result.drives_transferred = driver_result[:action] == :transferred
    end
  end
end