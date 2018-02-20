require 'rails_helper'

RSpec.describe CompanyMember, type: :model do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  describe 'create' do
    it 'should be possible to create a membership' do
      membership = CompanyMember.create user: user, company: company, role: CompanyMember::OWNER
      expect(membership).to be_persisted
    end

  end

  describe 'dependent' do
    subject { create(:company_member, user: user, company: company)}
    it 'should destroy membership when user is destroyed' do
      subject
      user.destroy
      expect{subject.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should not destroy user when membership is destroyed' do
      subject.destroy
      expect(user).not_to be_destroyed
    end
  end

  describe 'assign user email' do
    context 'existing user' do

      subject { CompanyMember.new user_email: user.email, company: company, role: CompanyMember::OWNER }

      it 'should be valid' do
        expect(subject).to be_valid
      end

      it 'should assign the user when save succeeds' do
        subject.save
        expect(subject.user).to eq user
      end

      it 'should not assign same user twice' do
        CompanyMember.create(user: user, company: company, role: CompanyMember::OWNER)
        expect(subject).not_to be_valid
      end

    end

    context 'non existing user' do
      subject { CompanyMember.new user_email: 'other email', company: company, role: CompanyMember::OWNER }

      it 'should give validation error' do
        expect(subject).not_to be_valid
      end

    end

  end

end
