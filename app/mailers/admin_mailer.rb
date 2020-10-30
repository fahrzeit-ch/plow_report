# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  default from: "notifactions@fahrzeit.ch"

  # Notify Admins about new user signup
  def signup_notification_mail
    recipients = ENV["SIGN_UP_NOTIFICATION_RECIPIENTS"]
    return if recipients.blank?

    mail(to: recipients, subject: "Neuer Benutzer hat sich registriert")
  end
end
