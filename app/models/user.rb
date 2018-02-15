class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: true

  has_many :driver_logins, dependent: :destroy
  has_many :drivers, through: :driver_logins

  has_many :company_members, dependent: :destroy
  has_many :companies, through: :company_members
  has_many :owned_companies, -> { where(company_members: { role: CompanyMember::OWNER }) },
           through: :company_members,
           class_name: 'Company',
           source: :company

  after_create :create_driver


  def owens_company
    !owned_companies.empty?
  end

  private
  def create_driver
    drivers.create(name: self.name)
  end
end
