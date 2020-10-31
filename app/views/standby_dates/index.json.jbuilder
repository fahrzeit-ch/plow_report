# frozen_string_literal: true

json.array! @standby_dates, partial: "standby_dates/standby_date", as: :standby_date
