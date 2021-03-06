# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company::RegistrationPolicy do
  subject { described_class.new(auth_context, company_registration) }
  let(:auth_context) { AuthContext.new(user, nil, nil) }
  let(:company_registration) { build(:company_registration) }

  let(:user) { create(:user) }
  context "signed in user" do
    it { is_expected.to permit_new_and_create_actions }
  end
end
