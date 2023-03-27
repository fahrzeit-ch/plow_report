# frozen_string_literal: true

class DynamicReports::ReportParameter < ApplicationRecord

  attribute :selection_list_config, DynamicReports::SelectionListConfig::Type.new

  def to_param_name
    "parameters[#{name}]"
  end

  def readonly?
    true
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end
end