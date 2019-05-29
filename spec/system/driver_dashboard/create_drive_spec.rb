require 'rails_helper'

feature 'creating a drive on the index drive page' do
  let(:user) { create(:user) }
  let(:current_driver) { user.drivers.last }
  let(:company) { create(:company) }
  let(:customer) { create(:customer, client_of: company) }

  before do
    company.add_member(user, CompanyMember::DRIVER)
    customer # create the customer (otherwise select will not be visible on open page)


    visit '/users/sign_in'
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: attributes_for(:user)[:password]
    click_button 'Anmelden'
    travel_to DateTime.new(2018, 8, 24, 12, 0)
  end

  after do
    travel_back
  end

  describe 'by filling in drive form' do
    let(:activity) { create(:value_activity, name: I18n.t('activerecord.attributes.drive.salt_refilled')) }
    before { activity }
    it 'should redirect to drives and show new drives' do
      visit drives_path
      # fill in start and end time
      attrs = { start: 1.hour.ago,
                end: 0.5.hour.ago,
                distance_km: 15.1,
                # customer: customer
      }
      fill_form 'drive', attrs
      # choose('drive[activity_execution_attributes][activity_id]', id: "activity_#{activity.id}")
      # fill_in 'drive[activity_execution_attributes][value]', with: 3.4

      # create drive
      click_button I18n.t('dashboard.cards.new_drive.create')

      expect(page).to have_current_path('/drives')

      # Test if drive is listed
      # drive options
      # expect(page).to have_content I18n.t('activerecord.attributes.drive.salt_refilled')
      # expect(page).to have_content '(3.41t)' # salt amount tonns
      expect(page).to have_content '15.1' # distance in km
      expect(page).to have_content '30min'
      # expect(page).to have_content customer.name
    end
  end

  context 'with existing drive of same type', js: true do
    # Currently skipping js tests until selenium is setup correctly
    let(:existing_drive) { create(:drive, driver: current_drive) }

    before { existing_drive }

    xit 'should pre populate the km field' do
      check 'drive[plowed]'
      expect(find_field(name: 'drive[distance_km]').value).to eq existing_drive.distance_km
    end

  end

end