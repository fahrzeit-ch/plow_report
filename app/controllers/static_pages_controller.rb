class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :demo_login]

  def home
  end

  def setup
  end

  def welcome
  end

  def demo_login
  end

  def determine_layout
    (action_name == 'setup') ? 'setup' : super
  end

end
