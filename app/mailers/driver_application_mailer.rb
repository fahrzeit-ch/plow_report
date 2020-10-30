# frozen_string_literal: true

class DriverApplicationMailer < ApplicationMailer
  def application_mail(application_id)
    @application = DriverApplication.find(application_id)
    mail(to: @application.recipient, subject: "#{@application.user.name} möchte als Fahrer hinzugefügt werden")
  end
end
