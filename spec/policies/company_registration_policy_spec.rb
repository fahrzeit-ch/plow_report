require 'rails_helper'

RSpec.describe Company::RegistrationPolicy do

  subject { described_class.new(user, company_registration) }
  let(:company_registration) { build(:company_registration) }

  let(:user) { create(:user) }
  context 'signed in user' do
    it { is_expected.to permit_new_and_create_actions }
  end
end
