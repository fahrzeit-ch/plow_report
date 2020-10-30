# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActivityExecution, type: :model do
  describe "validation" do
    subject { build(:activity_execution, activity: activity) }

    context "activity with has_values = true" do
      let(:activity) { create(:value_activity) }

      before { subject.value = nil }

      it { is_expected.not_to be_valid }
    end

    context "activity with has_values = false" do
      let(:activity) { create(:boolean_activity) }
      before { subject.value = nil }
      it { is_expected.to be_valid }
    end
  end

  describe "relations" do
    it { is_expected.to belong_to(:activity) }
    it { is_expected.to belong_to(:drive) }
  end
end
