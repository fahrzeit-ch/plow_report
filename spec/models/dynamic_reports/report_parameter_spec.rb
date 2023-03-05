# frozen_string_literal: true

require "rails_helper"

RSpec.describe DynamicReports::ReportParameter, type: :model do

  describe :to_query do
    subject { DynamicReports::ReportParameter.new name: "sample", parameter_type: "System.Int32", is_range: false, value: 212 }
    it "converts int to url query param" do
      expect(subject.to_query("parameters")).to eq("parameters%5Bsample%5D=212")
    end

    it "converts string values to url query param" do
      subject.value = "323"
      expect(subject.to_query("parameters")).to eq("parameters%5Bsample%5D=323")
    end

    it "converts date values to url query param" do
      subject.value = DateTime.parse("2022-12-12T12:39")
      expect(subject.to_query("parameters")).to eq("parameters%5Bsample%5D=2022-12-12T12%3A39%3A00%2B00%3A00")
    end

    it "escapes slashes" do
      subject.value = "some string / with slash"
      expect(subject.to_query("parameters")).to eq("parameters%5Bsample%5D=some+string+%2F+with+slash")
    end
  end

end
