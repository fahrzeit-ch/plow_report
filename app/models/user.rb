class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: true

  has_many :driver_logins, dependent: :destroy
  has_many :drivers, through: :driver_logins

  after_create :create_driver



  private
  def create_driver
    drivers.create(name: self.name)
  end
end
