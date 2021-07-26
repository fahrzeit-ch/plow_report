###
# A Daily Usage Report contains the number of unique sites recorded per tour
# on one day. If the same site was recorded in multiple tours on the same day
# it will be counted twice.
#
# Attributes:
# - name: The company name for this usage report
# - date_trunc: the day for this record
# - nr_of_drives: Sum of unique objects per tour
# - nr_of_tours: Number of tours started on this day
# - company_id: The company_id of the drivers on the tours
#
# Be aware, that only drives assigned to a tour are counted.
###
class Billing::DailyUsageReport < ApplicationRecord
  self.table_name_prefix = 'billing_'
  belongs_to :company

  scope :between, -> (start_day, end_day) { where(arel_table[:date_trunc]
                                          .gteq(start_day)
                                          .and(arel_table[:date_trunc].lt(end_day))) }

  # The Usage Report is only a DB View, so it is readonly
  def readonly?
    true
  end

  private

end