class Driver < ApplicationRecord
  has_one :driver_login, dependent: :destroy
  has_one :user, through: :driver_login

  validates :name, presence: true
end
