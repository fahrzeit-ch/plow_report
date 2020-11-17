# frozen_string_literal: true

class Vehicle < ApplicationRecord
  include Discard::Model
  validates :name, presence: true, length: { maximum: 50 }
  belongs_to :company
end
