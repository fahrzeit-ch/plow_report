# frozen_string_literal: true

class Customer < ApplicationRecord
  belongs_to :client_of, foreign_key: :company_id, class_name: "Company"
  has_many :drives, class_name: "Drive"
  has_many :sites, dependent: :destroy

  before_destroy :check_existing_drives

  validates :name, presence: true

  default_scope { order(:name) }

  audited

  include AddressSearch

  def display_name
    "#{name} #{first_name}"
  end

  def details
    ["#{street} #{nr}", city].reject(&:blank?).join(", ")
  end

  def as_select_value
    CustomerAssociation.new(id, nil).to_json
  end

  private
    def check_existing_drives
      if drives.any?
        errors.add :drives, "not_empty"
        throw :abort
      end
    end
end
