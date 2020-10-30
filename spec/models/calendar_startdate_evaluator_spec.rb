# frozen_string_literal: true

require "rails_helper"

RSpec.describe CalendarStartdateEvaluator, type: :model do
  describe "#resolve_start_date" do
    let(:params) { ActionController::Parameters.new }
    let(:season) { Season.current }

    subject { described_class.resolve_start_date(params, season) }

    context "with given season == current season" do
      context "without start_date param" do
        it { is_expected.to eq(Date.current) }
      end

      context "with given startdate in param" do
        let(:params) { ActionController::Parameters.new(start_date: Date.parse("2017-08-12")) }

        it { is_expected.to eq(Date.parse("2017-08-12")) }
      end
    end

    context "with past season" do
      let(:season) { Season.last(2)[0] } # Season.last returns num last seasons ending with current

      context "without standby dates" do
        context "without start_date param" do
          it "returns first date of season" do
            expect(subject).to eq(season.start_date)
          end
        end

        context "with given startdate in param" do
          let(:params) { ActionController::Parameters.new(start_date: Date.parse("2017-08-12")) }

          it { is_expected.to eq(Date.parse("2017-08-12")) }
        end
      end

      context "with existing standby dates" do
        before { create(:standby_date, day: season.start_date + 2.days) }
        before { create(:standby_date, day: season.start_date + 4.days) }

        context "without start_date param" do
          it "returns last standby date day in given season" do
            expect(subject).to eq(season.start_date + 4.days)
          end
        end

        context "with given startdate in param" do
          let(:params) { ActionController::Parameters.new(start_date: Date.parse("2017-08-12")) }

          it { is_expected.to eq(Date.parse("2017-08-12")) }
        end
      end
    end
  end
end
