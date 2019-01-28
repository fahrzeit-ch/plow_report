class Site < ApplicationRecord
  belongs_to :customer
  before_destroy :check_drives

  has_many :drives, class_name: 'Drive'

  validates :name, presence: true, uniqueness: { scope: :customer_id }

  scope :active, -> { where(active: true) }

  def details
    ["#{street} #{nr}", zip, city].reject(&:blank?).join(', ')
  end

  def as_select_value
    CustomerAssociation.new(customer_id, id).to_json
  end

  private

  def check_drives
    throw :abort unless drives.empty?
  end
end
