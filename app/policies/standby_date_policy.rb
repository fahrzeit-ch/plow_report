# frozen_string_literal: true

# Policy Standby Date
# Same rules apply as for Drives
class StandbyDatePolicy < DrivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
end
