# Defines a new registration of a company. Additionally to
# the information that is stored in the company, information about
# how to set up drivers etc. is provided in the registration class
class Company::Registration
  include ActiveModel::Model

  attr_accessor(:name, :contact_email, :owner, :add_owner_as_driver, :transfer_private_drives)

  # Takes a Company::Registration object and creates
  # the company. It returns a Company::RegistrationResult providing
  # data about the successful/unsuccessful steps
  def create
    result = Company::RegistrationResult.new
    result.registration = self
    company = Company.new(name: name, contact_email: contact_email)

    Company.transaction do
      # Create company
      result.company = company

      unless company.save
        # copy validation errors to registration model and return
        errors.copy!(company.errors)
        # registration.errors = company.errors
        result.has_errors = true
        return result
      end

      # Add owner as company member if this process fails, we it will fail the transaction
      member = company.add_member owner, CompanyMember::OWNER
      unless member.persisted?
        errors.add(:base, :unable_to_add_member)
        result.has_errors = true
        raise ActiveRecord::Rollback, 'Call tech support!'
      end

    end

    process_driver_setup(company, result)
    result
  end

  private

  # @param [Company] company
  # @param [Company::RegistrationResult] result
  # @return [Company::RegistrationResult]
  def process_driver_setup(company, result)
    if add_owner_as_driver
      driver_result = company.add_driver(owner,
                                         transfer_private_drives)
      result.driver_created = driver_result[:action] == :created
      result.drives_transferred = driver_result[:action] == :transferred
    end
  end
end