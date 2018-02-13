class CompanyMember < ApplicationRecord
  ROLES = %w(owner administrator driver)

  belongs_to :user
  belongs_to :company

  validates :role, presence: true, inclusion: ROLES

end
