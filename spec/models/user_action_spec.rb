# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserAction, type: :model do
  let(:user) { create(:user) }
  let(:records) { create_list(:drive, 2, driver: user.drivers.first) }

  before { user.create_personal_driver }

  describe "#track_list" do
    subject { described_class }

    it "creates a record for each record" do
      expect { described_class.track_list(user, records) }.to change(described_class, :count).by 2
    end
  end
end
