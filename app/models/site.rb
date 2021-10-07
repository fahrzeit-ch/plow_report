# frozen_string_literal: true

class Site < ApplicationRecord
  belongs_to :customer
  before_destroy :check_drives

  has_many :drives, class_name: "Drive"
  has_many :site_entries, dependent: :destroy, class_name: "DrivingRoute::SiteEntry"
  has_one :site_info, dependent: :destroy
  has_and_belongs_to_many :activities

  validates :display_name, presence: true, uniqueness: { scope: :customer_id }

  scope :active, -> { where(active: true) }

  attribute :name, :string, default: ""
  attribute :first_name, :string, default: ""
  attribute :city, :string, default: ""
  attribute :zip, :string, default: ""

  audited

  include Pricing::FlatRatable
  # creates #commitment_fee #commitment_fee_attributes=() #commitment_fee_for_date(date)
  flat_rate :commitment_fee

  # creates #travel_expense #travel_expense_attributes=() #travel_expense_for_date(date)
  flat_rate :travel_expense

  has_many :site_activity_flat_rates, dependent: :destroy
  accepts_nested_attributes_for :site_activity_flat_rates, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :site_info, allow_destroy: true, reject_if: :all_blank

  include AddressSearch

  def details
    ["#{name} #{first_name}", "#{street} #{nr}", "#{zip} #{city}"].reject(&:blank?).join(", ")
  end

  def area
    RGeo::GeoJSON.decode(area_json) unless area_json.keys.empty?
  end

  def area=(feature)
    self.area_json = RGeo::GeoJSON.encode(feature)
  end

  def area_features
    wrap_area(area_json).to_json
  end

  def area_features=(data)
    self.area_json = unwrap_area(JSON.parse(data))
  end

  def as_select_value
    CustomerAssociation.new(customer_id, id).to_json
  end

  def wrap_area(geometry)
    if geometry.empty?
      { type: "FeatureCollection", features: [] }
    else
      { type: "Feature", geometry: geometry }
    end
  end

  def unwrap_area(feature)
    return {} unless feature.is_a? Hash
    return {} unless feature["type"] == "Feature"
    feature["geometry"]
  end

  private
    def check_drives
      throw :abort unless drives.empty?
    end
end
