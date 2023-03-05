class DynamicReports::ReportParameter < ApplicationRecord

  attribute :selection_list_config, DynamicReports::SelectionListConfig::Type.new

  attr_accessor :value

  def to_query(key)
    value.to_query "#{key}[#{name}]"
  end

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