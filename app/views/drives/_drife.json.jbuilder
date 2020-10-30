# frozen_string_literal: true

json.extract! drive, :id, :start, :end, :distance_km, :salt_refilled, :salt_amount_tonns, :salted, :plowed, :created_at, :updated_at
json.url drive_url(drive, format: :json)
