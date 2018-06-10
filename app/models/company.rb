class AssignmentError < StandardError
end

class Company < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :options, presence: true, allow_blank: true
  validates :contact_email, presence: true

  has_many :company_members, dependent: :destroy
  has_many :users, through: :company_members
  has_many :drivers, dependent: :nullify
  has_many :drives, through: :drivers

  before_validation :default_values

  def add_member(user, role)
    company_members.create(user: user, role: role )
  end

  # Add a user as driver to the company. if transfer_private is set, the
  # default driver will be assigned to the company (if exists). Otherwise
  # a new driver for the user will be created and assigned to the company
  #
  # @param [User] user
  # @param [Boolean] transfer_private
  # @raise [AssignmentError] Raises error if the user already has a driver assigned to the company
  # @return [Hash] Result hash with :driver and :action, where :action is a symbol can be one of :new, :transferred
  def add_driver(user, transfer_private = false)
    raise AssignmentError, I18n.t('errors.drivers.already_assigned') if user.drives_for?(self)

    if transfer_private && ( transfer_driver = user.personal_driver )
      transfer_driver.update_attribute(:company_id, self.id)
      { driver: transfer_driver, action: :transferred }
    else
      new_driver = drivers.create!(name: user.name, user: user)
      { driver: new_driver, action: :created }
    end
  end

  # Returns companies that the given user_id has a membership with
  def self.with_member(user_id)
    joins(:company_members).where(company_members: {user_id: user_id})
  end

  def statistics(season)
    scope = drives
    if season
      scope = scope.by_season(season)
    end

    scope.select("EXtRACT(epoch FROM COALESCE(SUM(drives.end - drives.start), '00:00:00'::interval)) as duration,
COALESCE(SUM(drives.salt_amount_tonns), cast('0' as double precision)) as salt,
COALESCE(SUM(distance_km), cast('0' as double precision)) as distance")[0]
  end

  private
  def default_values
    self.options ||= {}
  end

end
