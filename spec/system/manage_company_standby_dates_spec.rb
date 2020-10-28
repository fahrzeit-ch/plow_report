require 'rails_helper'

feature 'view standby dates in calendar' do

  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:driver) { create(:driver, company: company) }

  before do
    company.add_member(user, CompanyMember::ADMINISTRATOR)
    sign_in_with(user.email, user.password)

    # assume we are in winter season 2018/2019
    travel_to Time.zone.local(2018, 11, 23, 12, 14)

    # we have some standby dates in this season and in the previous one
    create(:standby_date, driver: driver, day: Date.new(2018, 11, 15))
    create(:standby_date, driver: driver, day: Date.new(2017, 11, 15))
  end

  after do
    travel_back
  end

  it 'shows the calendar of the current month including existing standby date' do
    visit company_standby_dates_path(company)
    expect(page).to have_content('November 2018')
    within('.simple-calendar') do
      expect(page).to have_content(driver.name)
    end
  end

  it 'switches to the last standby date of the selected season' do
    visit company_standby_dates_path(company, season: '2017_2018')
    expect(page).to have_content('November 2017')
    within('.simple-calendar') do
      expect(page).to have_content(driver.name)
    end
  end

  context 'navigation outside selected_season' do
    it 'shows standby dates of other seasons as well' do
      visit company_standby_dates_path(company)
      expect(page).to have_content('November 2018')
      12.times do
        click_link('«')
      end
      expect(page).to have_content('November 2017')
      within('.simple-calendar') do
        expect(page).to have_content(driver.name)
      end
    end
  end

end