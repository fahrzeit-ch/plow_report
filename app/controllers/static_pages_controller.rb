# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :demo_login]
  skip_before_action :check_account!

  def home
  end

  def setup
  end

  def demo_login
  end

  def determine_layout
    (action_name == "setup") ? "setup" : super
  end
end
