require 'rails_helper'

RSpec.describe CompanyMember, type: :model do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  describe 'create' do
    it 'should be possible to create a membership' do
      membership = CompanyMember.create user: user, company: company, role: 'owner'
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

end
