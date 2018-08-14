class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home
  def home
  end

  def setup
  end

  def welcome
  end

end
