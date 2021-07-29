require 'rails_helper'

RSpec.describe Route, type: :model do
  subject { create(:route) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id) }
  it { is_expected.to validate_inclusion_of(:site_ordering).in_array([Route::ORDER_BY_DISTANCE, Route::CUSTOM_ORDER])}

  describe "add site entries" do
    subject { create(:route) }
    let(:customer) { create(:customer, client_of: subject.company) }
    let(:site1) { create(:site, customer: customer) }
    let(:site2) { create(:site, customer: customer) }

    it "creates entries" do
      expect {
        subject.site_entries.create(site: site1, position: 0)
      }.to change(Route::SiteEntry, :count).by 1
    end

    it "fails to create an entry with position < 0" do
      expect {
        subject.site_entries.create(site: site1, position: -1)
      }.to raise_error ActiveRecord::StatementInvalid
    end

    it "can mass assign site entries" do
      attrs = { site_entries_attributes: [{site_id: site1.to_param, position: 0}, { site_id: site2.to_param, position: 1}] }
      expect { subject.update(attrs) }.to change(Route::SiteEntry, :count).by 2
    end
  end
end
