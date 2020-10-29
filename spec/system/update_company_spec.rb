# frozen_string_literal: true

require "rails_helper"

feature "create company" do
  let(:owner) { create(:user, skip_create_driver: true) }
  let(:company) { create(:company) }

  before {
    company.add_member(owner, CompanyMember::OWNER)
  }

  context "signed in" do
    before do
      sign_in_with(owner.email, owner.password)
      visit(edit_company_path(company))
    end

    let(:new_attrs) { { name: "new name", contact_email: "new@mail.com", address: "new street 1", zip_code: "new zip", city: "new city" } }

    xit "is possible to navigate to company settings and change all attributes" do
      fill_form(:company, new_attrs)
      find("[type=submit]").click

      new_attrs.each_pair do |key, val|
        expect(page).to have_content(val)
      end
    end
  end
end
