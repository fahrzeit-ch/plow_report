module StandbyDatesHelper

  COLOR_MAP = %w(#fff #2de9fd #789A9F #EDF4F5 #F78F1E #FFEC94 #FFAEAE #FFF0AA #B0E57C #B4D8E7 #56BAEC)

  def driver_color(driver)
    COLOR_MAP[driver.id % 11]
  end

end
