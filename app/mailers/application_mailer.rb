# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@fahrzeit.ch"
  layout "mailer"
end
