class ReasonabilityCheckWarning < ApplicationRecord
  belongs_to :record, polymorphic: true
end
