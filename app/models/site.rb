# frozen_string_literal: true

class Site < ApplicationRecord
  belongs_to :customer
  before_destroy :check_drives

  has_many :drives, class_name: "Drive"

  validates :display_name, presence: true, uniqueness: { scope: :customer_id }

  scope :active, -> { where(active: true) }

  attribute :name, :string, default: ""
  attribute :first_name, :string, default: ""
  attribute :city, :string, default: ""
  attribute :zip, :string, default: ""

  audited

  include Pricing::FlatRatable
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
