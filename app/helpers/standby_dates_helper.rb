module StandbyDatesHelper

  COLOR_MAP = %w(#fff #054950 #789A9F #EDF4F5 #FFFFFF #F78F1E #FFEC94 #FFAEAE #FFF0AA #B0E57C #B4D8E7 #56BAEC)

  def driver_color(driver)
    COLOR_MAP[driver.id % 12]
  end

end
