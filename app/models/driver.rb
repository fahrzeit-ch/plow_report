class Driver < ApplicationRecord
  has_many :driver_logins, dependent: :destroy
  has_many :users, through: :driver_logins
  has_one :user, -> { first }
end
