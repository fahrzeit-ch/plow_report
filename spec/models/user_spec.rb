require 'rails_helper'

RSpec.describe User, type: :model do

  let(:valid_attributes) { { name: 'Some Name', email: 'my@valid.mail', password: 'secret', password_confirmation: 'secret' } }

  describe 'validation' do

    it 'should be valid with valid attributes' do
      expect(User.new(valid_attributes)).to be_valid
    end

    it 'should not be valid without name' do
      attrs = valid_attributes.except(:name)
      expect(User.new(attrs)).not_to be_valid
    end

  end

  describe '#owns_company' do
    let(:company) { create(:company) }
    subject { create(:user) }

    it 'should return true if its owner of a company' do
      CompanyMember.create(user: subject, company: company, role: CompanyMember::OWNER)
      expect(subject.owens_company).to be_truthy
    end

    it 'should return false if administrates company' do
      CompanyMember.create(user: subject, company: company, role: CompanyMember::ADMINISTRATOR)
      expect(subject.owens_company).to be_falsey
    end

    it 'should return false if no company' do
      expect(subject.owens_company).to be_falsey
    end

  end

  describe '#term_acceptance' do
    let!(:policy_term) { PolicyTerm.create(key: 'agb', description: 'dssd', name: 'nkn', required: true) }
    before { ENV['DEMO_ACCOUNT_EMAIL'] = 'demo@email.com'}
    context 'regular' do
      subject { build(:user) }
      before { subject.valid? }

      its(:errors) { is_expected.to have_key(:base) }
    end

    context 'demo account' do
      subject { build(:user, email: ENV['DEMO_ACCOUNT_EMAIL']) }
      before { subject.valid? }

      it { is_expected.to be_valid }
    end



  end


end
