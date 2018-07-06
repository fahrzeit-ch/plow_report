class PolicyTerm < ApplicationRecord
  scope :required, -> { where(required: true) }
  scope :optional, -> { where(required: false) }

  has_many :term_acceptances, dependent: :delete_all

  validates :key, uniqueness: true, presence: true
  validates :description, presence: true
  validates :name, presence: true

  audited
end
