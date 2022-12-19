# frozen_string_literal: true

class Customer < ApplicationRecord
  belongs_to :client_of, foreign_key: :company_id, class_name: "Company"
  has_many :drives, class_name: "Drive"
  has_many :sites, dependent: :destroy

  before_destroy :check_existing_drives

  validates :name, presence: { message: I18n.t('company_or_name_required') }, if: :company_name_blank?
  validates :company_name, presence: { message: I18n.t('company_or_name_required') }, if: :name_blank?

  default_scope { order_by_name }

  audited

  include AddressSearch

  def display_name
    _name = [name, first_name].reject(&:blank?).join(" ")
    [company_name, _name].reject(&:blank?).join(" - ")
  end

  def details
    ["#{street} #{nr}", city].reject(&:blank?).join(", ")
  end

  def as_select_value
    CustomerAssociation.new(id, nil).to_json
  end

  def self.order_by_name
    node = arel_table[:company_name].concat(arel_table[:name])
    order(node, arel_table[:first_name])
  end

  def self.with_site_names
    sites = Site.arel_table
    join = arel_table
             .join(sites, Arel::Nodes::OuterJoin)
             .on(
               arel_table[:id].eq(sites[:customer_id])
               .and(sites[:active].eq(true))
             )

    expression = [sites[:display_name], Arel::Nodes.build_quoted(", ")]
    string_agg = Arel::Nodes::NamedFunction.new("string_agg", expression)

    joins(join.join_sources)
      .select(arel_table[Arel.star], string_agg.as("site_names"))
      .group(arel_table[:id])
  end

  def self.concat_search_columns
    arel_table[:company_name]
      .concat(arel_table[:name])
      .concat(arel_table[:first_name])
      .concat(arel_table[:street])
      .concat(arel_table[:city])
  end

  private
    def company_name_blank?
      company_name.blank?
    end

    def name_blank?
      name.blank?
    end

    def check_existing_drives
      if drives.any?
        errors.add :drives, "not_empty"
        throw :abort
      end
    end
end
