require 'rails_helper'

RSpec.describe DriverApplication, type: :model do

  it { is_expected.to validate_presence_of(:recipient) }
  it { is_expected.to belong_to(:user) }

  describe 'create' do
    subject { create(:driver_application) }
    it 'is expected to send a notification mail' do
      expect do
        subject
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it(:token) { is_expected.not_to be_nil }
  end

  describe 'accept' do
    let(:company_admin) { create(:user) }
    let(:company) { create(:company) }

    subject { create(:driver_application) }
    before do
      subject.assign_attributes(assign_to_id: company.id)
      subject.accept accepted_by: company_admin
    end

    its(:accepted_to) { is_expected.to eq(company) }
    its(:accepted_by) { is_expected.to eq(company_admin) }
    its(:accepted_at) { is_expected.to be_within(2.seconds).of(DateTime.current) }

    it "assigns user as driver" do
      expect(subject.user.drives_for?(company)).to be_truthy
    end

    it 'add validation error when trying to accept again' do
      subject.accept accepted_by: company_admin
      expect(subject.errors[:base].size).to eq 1
    end
  end
end
