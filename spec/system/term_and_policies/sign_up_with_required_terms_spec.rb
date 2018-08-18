require 'rails_helper'

feature 'sign up as new user' do

  context 'wen no terms exist' do
    before { visit '/users/sign_up' }

    it 'will successfully create the user' do
      fill_form('user', attributes_for(:user))
      click_button(I18n.t('devise.sign_up'))
      expect(User.count).to eq 1
    end
  end

  context 'with required policies' do
    let(:policy) { create(:policy_term, required: true, key: :agb) }

    before do
      policy
      visit '/users/sign_up'
    end

    it 'forces the user to accept the policy' do
      fill_form('user', attributes_for(:user))
      click_button(I18n.t('devise.sign_up'))
      expect(page).to have_content(I18n.t('errors.attributes.base.consent_required'))
      fill_form('user', attributes_for(:user))
      check('user[terms][agb]')
      click_button(I18n.t('devise.sign_up'))
      expect(User.count).to eq 1
    end
  end

  context 'with optional terms' do
    let(:policy) { create(:policy_term, required: false, key: :agb) }

    before do
      policy
      visit '/users/sign_up'
    end

    it 'does not require the user to accept policy' do
      fill_form('user', attributes_for(:user))
      click_button(I18n.t('devise.sign_up'))
      expect(User.count).to eq 1
    end
  end

end