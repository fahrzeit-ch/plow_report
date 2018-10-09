module Company::CustomersHelper
  def company_customer
    @customer || Customer.new
  end
end