class CompanyMember < ApplicationRecord
  OWNER = 'owner'
  ADMINISTRATOR = 'administrator'
  EMPLOYEE = 'employee'
  DRIVER = 'driver'
  ROLES = [OWNER, ADMINISTRATOR, DRIVER]

  belongs_to :user, optional: true # set to true in order for to conditionally validate
  validates_presence_of :user, unless: :new_user?

  belongs_to :company

  attribute :user_email
  attribute :user_name

  attr_writer :warnings

  def warnings
    @warnings ||= []
  end

  before_validation :assign_user_by_email
  after_create :add_driver, if: :is_driver?

  validates :role, presence: true, inclusion: ROLES
  validates :user, uniqueness: { scope: :company }
  validates :user_name, presence: true, if: :new_user?

  def new_user?
    @new_user
  end

  def is_driver?
    role == DRIVER
  end

  def save_and_invite!(current_user)
    return unless valid?
    transaction do
      self.user = User.invite!({ email: user_email, name: user_name, skip_invitation: true, skip_create_driver: true }, current_user)
      self.save
      self.user.deliver_invitation
    end
    self
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
      @new_user = true
    end
  end


end
