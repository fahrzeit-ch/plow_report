module StandbyDatesHelper

  COLOR_MAP = %w(#fff #868e96 #373a3c #000 #2780E3 #6610f2 #613d7c #e83e8c #FF0039 #f0ad4e #FF7518 #3FB618 #bcffc5 #20c997 #9954BB #8A4117 #C36241)

  def driver_color(driver)
    COLOR_MAP[driver.id % 17]
  end

end
