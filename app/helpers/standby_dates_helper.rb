module StandbyDatesHelper

  COLOR_MAP = %w(#fff #2de9fd #789A9F #EDF4F5 #F78F1E #FFEC94 #FFAEAE #FFF0AA #B0E57C #B4D8E7 #56BAEC)

  def driver_color(driver)
    driver_color_by_id(driver.id)
  end

  def driver_color_by_id(id)
    COLOR_MAP[id % 11] + "77"
  end

end
