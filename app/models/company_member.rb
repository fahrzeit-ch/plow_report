class CompanyMember < ApplicationRecord
  OWNER = 'owner'
  ADMINISTRATOR = 'administrator'
  EMPLOYEE = 'employee'
  ROLES = [OWNER, ADMINISTRATOR, EMPLOYEE]

  belongs_to :user
  belongs_to :company

  attribute :user_email

  before_validation :assign_user_by_email
  validates :role, presence: true, inclusion: ROLES
  validates :user, uniqueness: { scope: :company }

  private
  def assign_user_by_email
    return if user_email.blank?

    self.user = User.find_by(email: user_email)
    self.errors.add(:user_email, :user_not_found) unless self.user
  end


end
