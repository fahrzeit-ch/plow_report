# frozen_string_literal: true

require "rails_helper"

feature "list drivers" do
  let(:company) { create(:company) }
  let(:owner) { create(:user) }
  let(:other_member) { create(:company_member, company: company, role: :owner) }

  let!(:drivers) { create_list(:driver, 2, company: company) }

  before do
    other_member
    company.add_member(owner, :owner)
    drivers.last.discard
    sign_in_with(owner.email, owner.password)
  end

  context "without inactive drivers" do
    before { visit company_drivers_path(company) }
    it "lists only drivers" do
      expect(page).to have_css("#company-member-" + company.drivers.kept.first.id.to_s)
      expect(page).not_to have_css("#company-member-" + company.drivers.discarded.first.id.to_s)
    end
  end

  context "with inactive drivers" do
    before { visit company_drivers_path(company, show_inactive: true) }
    it "lists only drivers" do
      expect(page).to have_css("#company-member-" + company.drivers.kept.first.id.to_s)
      expect(page).to have_css("#company-member-" + company.drivers.discarded.first.id.to_s)
    end
  end
end
