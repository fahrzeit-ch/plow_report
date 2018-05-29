require 'rails_helper'


feature 'record a drive from dashboard' do
  let(:user) { create(:user) }
  let(:current_driver) { user.drivers.last }

  before do
    sign_in_with(user.email, user.password)
  end

  describe 'start recording' do
    it 'should show currently recording form' do
      start_recording_drive

      # should "stay" on dashboard
      expect(page).to have_current_path('/')
      expect(page).to have_content(I18n.t('dashboard.cards.new_drive.recording_since'))
    end
  end

  describe 'finish recording' do

    before { current_driver.start_recording }

    it 'should go to drive list' do
      finish_recording_drive

      # start time should be disabled
      expect(page).to have_no_field 'drive[start]'

      # should redirect to drives
      expect(page).to have_current_path('/drives')
    end

    it 'should validate correctly' do
      finish_recording_drive do
        # fill in some invalid data
        fill_in 'drive[end]', with: 2.minute.ago.strftime('%H:%M')
      end

      # form should show us error
      expect(page).to have_content(I18n.t('errors.attributes.end.not_before_start'))

      # we want recording to have been stopped
      current_driver.reload
      expect(current_driver).not_to be_recording

      # now fill in some good stuff
      fill_in 'drive[end]', with: 1.minute.from_now.strftime('%H:%M')
      click_button('OK')

      expect(page).to have_content('Fahrten')
    end

  end

  describe 'cancel recording' do
    before { current_driver.start_recording }

    it 'should cancel recording and stay on dashboard' do
      visit '/'
      click_link_or_button I18n.t('dashboard.cards.new_drive.cancel_recording')

      expect(page).to have_current_path('/')
      current_driver.reload
      expect(current_driver).not_to be_recording
    end
  end

  describe 'create other drive while recording' do
    before { current_driver.start_recording }

    it 'should not stop current recording' do
      visit '/drives/new'

      fill_drive_form

      click_button 'OK'
      current_driver.reload
      expect(current_driver).to be_recording
      expect(page).to have_current_path('/drives')
      expect(page).to have_content('Fahrten')
    end

  end

end