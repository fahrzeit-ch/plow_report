require 'rails_helper'

RSpec.describe CustomerToSiteTransition, type: :model do

  let(:source) { create(:customer) }
  let(:assign_to) { create(:customer) }

  let(:affected_drives) { create_list(:drive, 2, customer: source) }

  let(:transition_object) { described_class.new(assign_to: assign_to, source: source) }

  describe '#affected drives' do
    subject { transition_object.affected_drives }

    it { is_expected.to include(*affected_drives) }
  end

  describe 'save' do
    before { affected_drives }

    subject { transition_object.save }
    it 'persists the target site' do
      expect(subject).to be_persisted
    end

    it 'destroys the source' do
      subject
      expect(source).to be_destroyed
    end

    it 'assigns the drives to the new site' do
      subject
      affected_drives.each do |drive|
        drive.reload
        expect(drive.site_id).to eq subject.id
        expect(drive.customer_id).to eq assign_to.id
      end
    end
  end

end
