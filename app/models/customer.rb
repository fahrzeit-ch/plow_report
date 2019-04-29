class Customer < ApplicationRecord
  belongs_to :client_of, foreign_key: :company_id, class_name: 'Company'
  has_many :drives, class_name: 'Drive'
  has_many :sites

  before_destroy :check_existing_drives

  validates :name, presence: true

  default_scope { order(:name) }

  def details
    [street, city].reject(&:blank?).join(', ')
  end

  def as_select_value
    CustomerAssociation.new(id, nil).to_json
  end

  private
  def check_existing_drives
    if drives.any?
      errors.add :drives, 'not_empty'
      throw :abort
    end
  end
end
