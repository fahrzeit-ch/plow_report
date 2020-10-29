# frozen_string_literal: true

class DriverLogin < ApplicationRecord
  belongs_to :user
  belongs_to :driver
end
