class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: true

  # drivers
  has_many :driver_logins, dependent: :destroy
  has_many :drivers, through: :driver_logins
  attribute :skip_create_driver, :boolean, default: false
  after_create :create_driver, unless: :skip_create_driver

  has_many :company_members, dependent: :destroy
  has_many :companies, through: :company_members

  def owned_companies
    self.companies_for_role CompanyMember::OWNER
  end

  def administrated_companies
    self.companies_for_role CompanyMember::ADMINISTRATOR
  end

  def companies_for_role(role)
    self.companies.where(company_members: { role: role } )
  end


  # this is useful when a user is invited but has not
  # set a name yet
  def name_or_email
    if name.blank?
      "(#{email})"
    else
      name
    end
  end

  def personal_driver
    drivers.personal.first
  end

  def has_driver?
    drivers.any?
  end

  def drives_for?(company)
    drivers.where(company: company).exists?
  end

  def create_personal_driver
    create_driver
  end

  def owens_company
    !owned_companies.empty?
  end

  private

  def create_driver
    raise "Personal driver already exists for user #{self.id}" unless personal_driver.nil?
    drivers.create(name: self.name)
  end
end
