require 'rails_helper'

RSpec.describe SiteActivityFlatRate, type: :model do

  describe "activity_fee" do
    it { is_expected.to respond_to(:activity_fee) }
    describe "build" do
      subject { described_class.new.activity_fee }

      it "builds activity_fee that is active by default" do
        expect(subject).to be_active
      end
    end
  end

  describe "validation" do
    subject { build(:site_activity_flat_rate) }
    it { is_expected.to validate_uniqueness_of(:activity_id).scoped_to(:site_id) }
  end

  describe "deletion" do
    subject { create(:site_activity_flat_rate) }

    context "without drives using activity and site" do
      before do
        subject
        # create an updated flatrate
        subject.update!(activity_fee_attributes: { valid_from: Season.next.start_date, active: true, price: "30" })
      end

      it "deletes all flat rates" do
        expect { subject.destroy }.to change(Pricing::FlatRate, :count).by(-2)
      end

      it "gets deleted" do
        expect { subject.destroy }.to change(SiteActivityFlatRate, :count).by(-1)
      end
    end

    context "with associated drives" do
      let!(:drive) { create(:drive, site: subject.site, activity: subject.activity) }

      # make sure subject is created before tests run
      before { subject }

      it "deletes all flat rates" do
        expect { subject.destroy }.not_to change(Pricing::FlatRate, :count)
      end

      it "gets deleted" do
        expect { subject.destroy }.not_to change(SiteActivityFlatRate, :count)
      end
    end
  end

end
