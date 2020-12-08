# frozen_string_literal: true

require "rails_helper"

feature "Search Customers" do
  context "as compnay admin" do
    let(:company_admin) { create(:user) }
    let(:company) { create(:company) }

    let!(:customers) { create_list(:customer, 31, client_of: company).sort_by { |c| c.name } }

    before do
      company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
      sign_in_with(company_admin.email, company_admin.password)
      visit(company_customers_path(company))
    end

    it "lists the first 30 customers" do
      customers.first(30).each do |c|
        expect(page).to have_content(c.name)
      end
      expect(page).not_to have_content(customers.last.name)
    end

    it "displays search query and results" do
      fill_in("q", with: customers.last.name)
      click_on("search")

      # It has one result item
      expect(page).to have_link(I18n.t('views.companies.customers.edit'), href: edit_company_customer_path(company, customers.last))
      expect(page).to have_selector('ul#customers > li', count: 1)

      # clear search will show all 30 items again
      click_on(I18n.t('common.clear_search'))
      expect(page).to have_selector('ul#customers > li', count: 30)
    end

    it "shows no results info when nothing found" do
      fill_in("q", with: "StringThatMatchesNothing")
      click_on("search")

      # It has one item that says no result
      expect(page).to have_content(I18n.t('views.companies.customers.empty_info_title_search'))
      expect(page).to have_selector('ul#customers > li', count: 1)

      click_on(I18n.t('common.clear_search'))
      expect(page).to have_selector('ul#customers > li', count: 30)
    end
  end
end
