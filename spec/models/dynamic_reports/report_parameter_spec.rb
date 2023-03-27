# frozen_string_literal: true

require "rails_helper"

RSpec.describe DynamicReports::ReportParameter, type: :model do

  describe :to_query do
    subject { DynamicReports::ReportParameter.new name: "sample", parameter_type: "System.Int32", is_range: false }
    its(:to_param_name) { is_expected.to eq("parameters[sample]")}
  end

end
