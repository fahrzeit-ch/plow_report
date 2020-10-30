# frozen_string_literal: true

require "rails_helper"

feature "accept invitation" do
  let(:invited_by) { u = build(:user); u.save!(validate: false); u }
  let(:company_member) { build(:company_member_invite, role: :driver).save_and_invite!(invited_by) }
  let(:invitation_token) { company_member.user.raw_invitation_token }

  let(:gtc) { create(:policy_term, required: true) }

  before { gtc }

  it "should be possible to sign up by invite" do
    visit "/users/invitation/accept?invitation_token=#{invitation_token}"
    fill_in("user[password]", with: "password")
    fill_in("user[password_confirmation]", with: "password")

    check("user[terms][agb]")

    click_button(I18n.t "devise.invitations.edit.submit_button")
    expect(page).to have_current_path("/")
  end
end
