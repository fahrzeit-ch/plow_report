# Configures which attributes will be enabled
# for drives.
class DriveOptions
  # Track the distance of a drive.
  attr_accessor :track_distance

  # Track if the drive includes salt refill. If enabled
  # it allows also to track amount of salt that was refilled
  attr_accessor :track_salt_refill

  # Allow to set the drive type to salting
  attr_accessor :track_salting

  # Allow to set the drive type to plowing
  attr_accessor :track_plowing

  def initialize(attributes)
    attributes ||= {}
    attributes = defaults.merge attributes.symbolize_keys!
    self.track_distance = !attributes[:track_distance]
    self.track_salt_refill = !attributes[:track_salt_refill]
    self.track_salting = !attributes[:track_salting]
    self.track_plowing = !attributes[:track_plowing]
  end

  private

  def defaults
    {
        track_distance: true,
        track_salt_refill: true,
        track_plowing: true,
        track_salting: true
    }
  end
end