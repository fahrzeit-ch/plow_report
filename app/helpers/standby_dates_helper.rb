module StandbyDatesHelper

  COLOR_MAP = %w(#00AEFF #ff7319 #f0ad4e #FF7518 #3FB618 #20c997 #9954BB #868e96)

  def driver_color(driver)
    COLOR_MAP[driver.id % 8]
  end

end
