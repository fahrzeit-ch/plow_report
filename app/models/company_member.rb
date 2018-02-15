class CompanyMember < ApplicationRecord
  OWNER = 'owner'
  ADMINISTRATOR = 'administrator'
  DRIVER = 'driver'
  ROLES = [OWNER, ADMINISTRATOR, DRIVER]

  belongs_to :user
  belongs_to :company

  validates :role, presence: true, inclusion: ROLES

end
