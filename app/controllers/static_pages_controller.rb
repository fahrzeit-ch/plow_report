# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :demo_login]
  skip_before_action :check_account!
  skip_before_action :check_not_app_login!

  def account_error
    NewRelic::Agent.notice_error(StandardError.new("Account error for: User<#{current_user.id}> Drivers<#{current_user.drivers.pluck(:id).join(",")}>"))
  end

  def setup
  end

  def is_app_login_error
  end

  def demo_login
  end

  def determine_layout
    (action_name == "setup") ? "setup" : super
  end
end
