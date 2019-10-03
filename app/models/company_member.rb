class CompanyMember < ApplicationRecord
  OWNER = 'owner'.freeze
  ADMINISTRATOR = 'administrator'.freeze
  EMPLOYEE = 'employee'.freeze
  DRIVER = 'driver'.freeze
  ROLES = [OWNER, ADMINISTRATOR, DRIVER]

  belongs_to :user, optional: true # set to true in order for to conditionally validate
  validates_presence_of :user, unless: :new_user?

  belongs_to :company
  scope :owners, -> { where(role: OWNER) }

  attribute :user_email
  attribute :user_name

  attr_writer :warnings

  def warnings
    @warnings ||= []
  end

  before_validation :assign_user_by_email
  after_create :add_driver, if: :driver?
  after_destroy :remove_driver_login, if: :has_driver?

  validates :role, presence: true, inclusion: ROLES
  attribute :role, :string, default: DRIVER
  validates :user, uniqueness: { scope: :company }
  validates :user_name, presence: true, if: :new_user?

  def new_user?
    @new_user
  end

  def driver?
    role == DRIVER
  end

  def owner?
    role == OWNER
  end

  def admin?
    role == ADMINISTRATOR
  end

  def has_driver?
    !!driver
  end

  def driver
    user.drivers.find_by(company_id: company.id)
  end

  def remove_driver_login
    driver.driver_login.destroy
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

  def resend_invitation!
    user.invite!
  end

  # Destroys this company member only if there is
  # at least one other owner in the same company
  def destroy_unless_owner
    if last_owner?
      errors.add(:base, :last_owner)
      false
    else
      destroy
    end
  end

  # Returns true if this is the last
  def last_owner?
    @last_owner ||= owner? && self.class
                        .where(company: company)
                        .owners.size == 1
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

  def self.role_of(user, company)
    company.company_members
        .where(user_id: user.id)
        .limit(1)
        .pluck(:role)
        .first
  end


end
