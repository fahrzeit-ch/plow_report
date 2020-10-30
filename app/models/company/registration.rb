# frozen_string_literal: true

# Defines a new registration of a company. Additionally to
# the information that is stored in the company, information about
# how to set up drivers etc. is provided in the registration class
class Company::Registration
  include ActiveModel::Model

  attr_reader :add_owner_as_driver, :transfer_private_drives
  attr_accessor :name,
                :contact_email,
                :address,
                :nr,
                :zip_code,
                :city,
                :owner,
                :company

  # Takes a Company::Registration object and creates
  # the company. It returns a Company::RegistrationResult providing
  # data about the successful/unsuccessful steps
  def create
    result = Company::RegistrationResult.new self

    Company.transaction do
      create_company(result)
      result.company = self.company
      return result if result.has_errors
      add_owner(result)
    end
    process_driver_setup(result)
  end

  def add_owner_as_driver=(val)
    @add_owner_as_driver = cast_boolean(val)
  end

  def transfer_private_drives=(val)
    @transfer_private_drives = cast_boolean(val)
  end

  private
    def cast_boolean(val)
      ActiveModel::Type::Boolean.new.cast(val)
    end

    def add_owner(result)
      member = company.add_member owner, CompanyMember::OWNER
      return if member.persisted?

      errors.add(:base, :unable_to_add_member)
      result.has_errors = true
      raise ActiveRecord::Rollback, "Call tech support!"
    end

    def create_company(result)
      self.company = Company.new(name: name,
                                 contact_email: contact_email,
                                 address: address,
                                 nr: nr || "", # nr is but null is not accepted
                                 zip_code: zip_code,
                                 city: city)
      if company.save
        # create default activities
        Activity.default.each { |a| a.clone_to!(company) }
      else
        # copy validation errors to registration model and return
        errors.copy!(company.errors)
        # registration.errors = company.errors
        result.has_errors = true
      end
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
