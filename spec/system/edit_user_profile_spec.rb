require 'rails_helper'

feature 'edit user profile' do

  let(:user) { create(:user) }
  let(:new_attributes) { {name: 'My new Name', email: 'new@email.com', current_password: user.password} }

  context 'Without updating password' do
    before do
      sign_in_with(user.email, user.password)
      visit(edit_user_registration_path)
      fill_form('user', new_attributes)
      click_button(I18n.t('devise.registrations.edit.update'))
    end

    it  do
      expect(page).to have_current_path('/')
      user.reload
      expect(user.name).to eq new_attributes[:name]
    end

  end

end