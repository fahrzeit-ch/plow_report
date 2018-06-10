class Company::RegistrationResult
  attr_accessor :registration, :driver_created, :drives_transferred, :company, :has_errors

  def initialize(registration, company = nil)
    @registration = registration
    @company = company
  end
end