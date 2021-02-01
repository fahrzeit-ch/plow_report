require 'rails_helper'

RSpec.describe ToursReport, type: :model do
  it { is_expected.to respond_to(:date_range) }

  describe "date range" do
    subject { described_class.new(date_range: "2021-01-01T00:00 - 2021-01-31T23:59") }
    its(:start_date) { is_expected.to eq(DateTime.parse("2021-01-01T00:00")) }
    its(:end_time) { is_expected.to eq(DateTime.parse("2021-01-31T23:59")) }
  end
end
