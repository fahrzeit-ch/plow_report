require 'rails_helper'

RSpec.describe Customer, type: :model do

  subject { build(:customer) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:client_of) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id) }

  describe '#destroy' do
    let(:customer) { create(:customer) }
    subject { customer.destroy }
    context 'without tracked drives' do
      it { is_expected.to be_truthy }
    end

    context 'wihth existing drives' do
      before { create(:drive, customer: customer) }
      it { is_expected.to be_falsey }
    end
  end

end
