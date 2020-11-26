# frozen_string_literal: true

require "rails_helper"

feature "authenticate via oauth" do
  let!(:app) { Doorkeeper::Application.create!(name: "test", scopes: "profile email phone address", confidential: false, redirect_uri: "https://www.example.com", default_app: true) }

  describe "login with existing user" do
    let(:password) { "password" }
    let!(:user) { create(:user, password: password, password_confirmation: password) }

    it "will show signin page" do
      query = URI.encode_www_form({ response_type: "code", state: "", client_id: app.uid, scope: "profile email phone address", redirect_uri: app.redirect_uri })
      visit "/oauth/authorize?#{query}"
      expect(page).to have_content("E-Mail")
      expect(page).to have_content("Passwort")
    end

    it "signing in will redirect to redirect_uri" do
      query = URI.encode_www_form({ response_type: "code", state: "", client_id: app.uid, scope: "profile email phone address", redirect_uri: app.redirect_uri })
      visit "/oauth/authorize?#{query}"
      fill_form "user", { email: user.email, password: password }
      click_button I18n.t("devise.sign_in")
      expect(current_url).to start_with(app.redirect_uri)
    end

    context "with terms not accepted" do
      let!(:term) { create(:policy_term, required: true) }
      it "redirects to accept terms" do
        query = URI.encode_www_form({ response_type: "code", state: "", client_id: app.uid, scope: "profile email phone address", redirect_uri: app.redirect_uri })
        visit "/oauth/authorize?#{query}"
        fill_form "user", { email: user.email, password: password }
        click_button I18n.t("devise.sign_in")

        expect(page).to have_content(term.name)
        check "user[terms][agb]"
        click_on "Weiter"
        expect(current_url).to start_with(app.redirect_uri)
      end
    end
  end

  describe "sign up with new user" do
    let(:password) { "password" }
    let(:user) { attributes_for(:user) }

    it "will show signin page" do
      query = URI.encode_www_form({ response_type: "code", state: "", client_id: app.uid, scope: "profile email phone address", redirect_uri: app.redirect_uri })
      visit "/oauth/authorize?#{query}"
      expect(page).to have_link(I18n.t("devise.shared.links.sign_up"))
    end

    it "signing in will redirect to redirect_uri" do
      query = URI.encode_www_form({ response_type: "code", state: "", client_id: app.uid, scope: "profile email phone address", redirect_uri: app.redirect_uri })
      visit "/oauth/authorize?#{query}"
      within "#navbarSupportedContent" do
        click_link I18n.t("devise.shared.links.sign_up")
      end
      fill_form "user", { name: user[:name], email: user[:email], password: password, password_confirmation: password }
      click_button I18n.t("devise.shared.links.sign_up")
      expect(current_url).to start_with(app.redirect_uri)
    end
  end
end
