require 'rails_helper'

RSpec.describe Activity, type: :model do

  describe 'validation' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id) }
  end

  describe 'relations' do
    it { is_expected.to belong_to(:company) }
  end

  describe '#destroy' do
    let(:activity) { create(:activity) }
    context 'with activity executions assigned' do
      before { create(:drive, activity: activity) }

      subject { activity.destroy }
      it 'raises error' do
        expect { subject }.to raise_error
      end
    end
  end


end
