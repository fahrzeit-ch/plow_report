# Defines a new registration of a company. Additionally to
# the information that is stored in the company, information about
# how to set up drivers etc. is provided in the registration class
class Company::Registration
  include ActiveModel::Model

  attr_accessor(:name, :contact_email, :owner, :add_owner_as_driver, :transfer_private_drives)

end