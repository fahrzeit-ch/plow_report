class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include AcceptsTerms

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

  def company_admin_or_owner?(company)
    return false if company.nil?
    return @_company_admin_or_owner if @_company_admin_or_owner
    @_company_admin_or_owner = companies_for_role([CompanyMember::ADMINISTRATOR, CompanyMember::OWNER]).exists? company.id
  end

  def company_member?(company)
    return false if company.nil?
    return @_company_member if @_company_member
    @_company_member = companies.exists? company.id
  end

  def self.available_as_driver(company)
    # Get users that are assigned as drivers on this company
    user_ids = DriverLogin.select(:user_id).joins(:driver)
                   .where(drivers: {company_id: company.id} )

    company.users.where.not(id: user_ids)
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
