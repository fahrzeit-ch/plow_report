# frozen_string_literal: true

class Vehicle < ApplicationRecord
  include Discard::Model
  validates :name, presence: true, length: { maximum: 50 }
  validates_uniqueness_of :name, scope: [:company_id, :discarded_at], unless: :discarded?
  belongs_to :company
end
