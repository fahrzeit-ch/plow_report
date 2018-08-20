require 'rails_helper'

feature 'jump to today in calendar' do

  let(:user) { create(:user) }
  let(:driver) { user.drivers.first }

  before do
    sign_in_with(user.email, user.password)

    # assume we are in winter season 2018/2019
    travel_to Time.zone.local(2018, 11, 23, 12, 14)
  end

  it 'jumps to the current month' do
    visit '/standby_dates'
    expect(page).to have_content('November 2018')

    click_link('«')
    expect(page).to have_content('Oktober 2018')
    click_link(I18n.t'simple_calendar.jump_to_today')
    expect(page).to have_content('November 2018')
  end

end