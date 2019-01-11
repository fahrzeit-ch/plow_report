class Site < ApplicationRecord
  belongs_to :customer

  validates :name, presence: true, uniqueness: { scope: :customer_id }

  scope :active, -> { where(active: true) }

  def details
    ["#{street} #{nr}", zip, city].reject(&:blank?).join(', ')
  end
end
