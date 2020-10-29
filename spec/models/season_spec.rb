# frozen_string_literal: true

require "rails_helper"

RSpec.describe Season, type: :model do
  describe "class_methods" do
    describe "#current" do
      subject { Season.current }

      it "should return a season instance" do
        expect(subject).to be_a(Season)
      end

      it "should be within current date range" do
        expect(subject.start_date < Date.today && Date.today < subject.end_date).to be_truthy
      end
    end
  end

  describe "instance methods" do
    describe "equality" do
      subject { described_class.from_date(Date.parse("2018-01-01")) }

      it { is_expected.to eq(described_class.from_date(Date.parse("2017-11-11"))) }
      it { is_expected.not_to eq(described_class.from_date(Date.parse("2016-01-01"))) }
    end
  end
end
