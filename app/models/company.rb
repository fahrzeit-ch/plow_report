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

  # Returns companies that the given user_id has a membership with
  def self.with_member(user_id)
    joins(:company_members).where(company_members: {user_id: user_id})
  end

  def statistics(season)
    scope = drives
    if season
      scope = scope.by_season(season)
    end

    scope.select("COALESCE(SUM(drives.end - drives.start), '00:00:00'::interval) as duration,
COALESCE(SUM(drives.salt_amount_tonns), cast('0' as double precision)) as salt,
COALESCE(SUM(distance_km), cast('0' as double precision)) as distance")[0]
  end

  private
  def default_values
    self.options ||= {}
  end

end
