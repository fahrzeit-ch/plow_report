# Defines a new registration of a company. Additionally to
# the information that is stored in the company, information about
# how to set up drivers etc. is provided in the registration class
class Company::Registration
  include ActiveModel::Model

  attr_accessor(:name, :contact_email, :owner, :add_owner_as_driver, :transfer_private_drives, :company)

  # Takes a Company::Registration object and creates
  # the company. It returns a Company::RegistrationResult providing
  # data about the successful/unsuccessful steps
  def create
    result = Company::RegistrationResult.new self

    Company.transaction do
      create_company(result)
      result.company = self.company
      return if result.has_errors
      add_owner(result)
    end
    process_driver_setup(result)
  end

  private

  def add_owner(result)
    member = company.add_member owner, CompanyMember::OWNER
    return if member.persisted?

    errors.add(:base, :unable_to_add_member)
    result.has_errors = true
    raise ActiveRecord::Rollback, 'Call tech support!'
  end

  def create_company(result)
    self.company = Company.new(name: name, contact_email: contact_email)
    return if company.save

    # copy validation errors to registration model and return
    errors.copy!(company.errors)
    # registration.errors = company.errors
    result.has_errors = true
  end

  # @param [Company::RegistrationResult] result
  # @return [Company::RegistrationResult]
  def process_driver_setup(result)
    return result unless add_owner_as_driver
    driver_result = company.add_driver(owner,
                                       transfer_private_drives)
    result.driver_created = driver_result[:action] == :created
    result.drives_transferred = driver_result[:action] == :transferred
    result
  end
end