# frozen_string_literal: true

require "rails_helper"

RSpec.describe CustomerSuggestor, type: :model do
  let(:site_ids) { [1, 2, 3] }
  let(:drives) { [] }

  subject { described_class.suggest(drives) }

  it { is_expected.to be_a(CustomerAssociation) }

  context "given a driver" do
    context "without existing drives" do
      it { is_expected.to be_blank }
    end

    context "with 1 existing drive" do
      let(:drives) { [build(:drive, end: (1.day.ago + 30.minutes), site_id: site_ids[1]) ] }

      it { is_expected.to be_blank }
    end

    context "with the last drive having a site that does not yet exist twice in the drive history" do
      let(:drive_site_b) { build(:drive, end: (1.day.ago + 30.minutes), site_id: site_ids[1]) }
      let(:drive_site_c) { build(:drive, end: (1.day.ago + 30.minutes), site_id: site_ids[2]) }

      let(:drive_site_just_recent) { build(:drive, end: Time.now, site_id: site_ids[0]) }

      let(:drives) { [
        drive_site_b,
        drive_site_c,
        drive_site_just_recent
      ]}

      it { is_expected.to be_blank }
    end

    context "with the last drive having a site that is referenced in a drive before" do
      let(:drive_site_b) { build(:drive, end: 1.day.ago, site_id: site_ids[1]) }
      let(:drive_site_a_time_before) { build(:drive, end: (1.day.ago + 30.minutes), site_id: site_ids[0]) }
      let(:drive_site_c) { build(:drive, end: (1.day.ago + 33.minutes), site_id: site_ids[2]) }
      let(:drive_site_just_recent) { build(:drive, end: Time.now, site_id: site_ids[0]) }

      let(:drives) { [
        drive_site_b,
        drive_site_just_recent,
        drive_site_c,
        drive_site_a_time_before
      ]}

      it { is_expected.to eq(CustomerAssociation.new(nil, site_ids[2])) }
    end
  end
end
