class CompanyMember < ApplicationRecord
  OWNER = 'owner'
  ADMINISTRATOR = 'administrator'
  EMPLOYEE = 'employee'
  DRIVER = 'driver'
  ROLES = [OWNER, ADMINISTRATOR, DRIVER]

  belongs_to :user
  belongs_to :company

  attribute :user_email

  attr_writer :warnings

  def warnings
    @warnings ||= []
  end

  before_validation :assign_user_by_email
  after_create :add_driver, if: :is_driver?

  validates :role, presence: true, inclusion: ROLES
  validates :user, uniqueness: { scope: :company }

  def new_user?
    @new_user
  end

  def is_driver?
    role == DRIVER
  end

  def save_and_invite!(current_user)
    transaction do
      self.user = User.invite!({ email: user_email, skip_invitation: true }, current_user)
      if self.save
        self.user.deliver_invitation
      end
    end
  end

  private
  def add_driver
    company.add_driver user
  rescue AssignmentError => e
    Rails.logger.warn(e.message)
    self.warnings << e.message
  end

  def assign_user_by_email
    return if user_email.blank? || !user.blank?

    self.user = User.find_by(email: user_email)
    unless self.user
      self.errors.add(:user_email, :user_not_found)
      @new_user = true
    end
  end


end
