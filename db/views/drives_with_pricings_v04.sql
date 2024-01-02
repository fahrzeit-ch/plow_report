SELECT DISTINCT
    drive_grouped.tour_id,
    drive_grouped.customer_id,
    s.display_name AS site_name,
    drive_grouped.start at time zone 'utc' at time zone 'Europe/Zurich' as "start",
    drive_grouped.vehicle_id,
    v.NAME AS vehicle,
    a.NAME AS activity,
    ae.value AS activitiy_value,
    phr.price_cents AS hourly_rate,
    pfr.price_cents AS site_flat_rate,
    drive_grouped."end" - drive_grouped.start AS duration,
    drive_grouped.total_drives_duration,
    t.end_time - t.start_time AS tour_duration,
    CASE WHEN drive_grouped.first_in_tour = 1 THEN true ELSE false END AS first_item,
    date_part(
            'epoch' :: text, drive_grouped."end" - drive_grouped.start
        ) AS duration_seconds,
    v.company_id,
    d.NAME AS driver_name,
    d.id AS driver_id,
    a.value_label AS activity_value_label,
    a.has_value AS has_activity_value,
    drive_grouped.num_billed_empty_drives,
    CASE WHEN (
                      t.end_time - t.start_time - drive_grouped.total_drives_duration
                  ) < '00:00:00' :: interval
  OR NOT drive_grouped.first_in_tour = 1 THEN '00:00:00' :: interval ELSE t.end_time - t.start_time - drive_grouped.total_drives_duration end / drive_grouped.num_billed_empty_drives :: DOUBLE PRECISION AS billed_empty_drive_time,
  vphr.price_cents AS vehicle_price,
  date_part(
    'epoch' :: text,
    CASE WHEN (
      t.end_time - t.start_time - drive_grouped.total_drives_duration
    ) < '00:00:00' :: interval
    OR NOT drive_grouped.first_in_tour = 1 THEN '00:00:00' :: interval ELSE t.end_time - t.start_time - drive_grouped.total_drives_duration END / drive_grouped.num_billed_empty_drives :: DOUBLE PRECISION
  ) AS billed_empty_drive_time_seconds,
  vpfr.price_cents AS vehicle_flatrate_price
FROM
  (
    SELECT
      sum(
        drive_with_tour_info.first_in_tour
      ) OVER (
        partition BY drive_with_tour_info.tour_id
      ) AS num_billed_empty_drives,
      drive_with_tour_info.id,
      drive_with_tour_info.start,
      drive_with_tour_info."end",
      drive_with_tour_info.created_at,
      drive_with_tour_info.updated_at,
      drive_with_tour_info.driver_id,
      drive_with_tour_info.customer_id,
      drive_with_tour_info.site_id,
      drive_with_tour_info.discarded_at,
      drive_with_tour_info.tour_id,
      drive_with_tour_info.vehicle_id,
      drive_with_tour_info.first_in_tour,
      drive_with_tour_info.total_drives_duration
    FROM
      (
        SELECT
          drives.id,
          drives.start,
          drives."end",
          drives.created_at,
          drives.updated_at,
          drives.driver_id,
          drives.customer_id,
          drives.site_id,
          drives.discarded_at,
          drives.tour_id,
          drives.vehicle_id,
          CASE WHEN row_number() OVER (
            partition BY drives.tour_id,
            drives.site_id
            ORDER BY
              drives.start
          ) = 1 THEN 1 ELSE 0 END AS first_in_tour,
          sum(drives."end" - drives.start) OVER (partition BY drives.tour_id) AS total_drives_duration
        FROM
          drives
        WHERE
          drives.discarded_at IS NULL
      ) drive_with_tour_info
  ) drive_grouped
  JOIN activity_executions ae ON ae.drive_id = drive_grouped.id
  JOIN activities a ON a.id = ae.activity_id
  JOIN tours t ON t.id = drive_grouped.tour_id
  JOIN vehicles v ON v.id = drive_grouped.vehicle_id
  JOIN sites s ON s.id = drive_grouped.site_id
  JOIN drivers d ON d.id = drive_grouped.driver_id
  LEFT JOIN site_activity_flat_rates safr ON safr.site_id = drive_grouped.site_id
  AND safr.activity_id = ae.activity_id
  LEFT JOIN pricing_flat_rates pfr ON pfr.id = (
    (
      SELECT
        pricing_flat_rates.id
      FROM
        pricing_flat_rates
      WHERE
        pricing_flat_rates.flat_ratable_type :: text = 'SiteActivityFlatRate' :: text
        AND pricing_flat_rates.flat_ratable_id = safr.id
        AND pricing_flat_rates.rate_type :: text = 'activity_fee' :: text
        AND pricing_flat_rates.valid_from < drive_grouped.start
        AND pfr.active = true
      ORDER BY
        pricing_flat_rates.valid_from DESC
      limit
        1
    )
  )
  LEFT JOIN vehicle_activity_assignments vaa ON vaa.vehicle_id = drive_grouped.vehicle_id
  AND vaa.activity_id = ae.activity_id
  LEFT JOIN pricing_hourly_rates phr ON phr.id = (
    (
      SELECT
        pricing_hourly_rates.id
      FROM
        pricing_hourly_rates
      WHERE
        pricing_hourly_rates.hourly_ratable_type :: text = 'VehicleActivityAssignment' :: text
        AND pricing_hourly_rates.hourly_ratable_id = vaa.id
        AND pricing_hourly_rates.valid_from < drive_grouped.start
      ORDER BY
        pricing_hourly_rates.valid_from DESC
      limit
        1
    )
  )
  LEFT JOIN pricing_hourly_rates vphr ON vphr.id = (
    (
      SELECT
        pricing_hourly_rates.id
      FROM
        pricing_hourly_rates
      WHERE
        pricing_hourly_rates.hourly_ratable_type :: text = 'Vehicle' :: text
        AND pricing_hourly_rates.hourly_ratable_id = drive_grouped.vehicle_id
        AND pricing_hourly_rates.valid_from < drive_grouped.start
      ORDER BY
        pricing_hourly_rates.valid_from DESC
      limit
        1
    )
  )
  LEFT JOIN pricing_flat_rates vpfr ON vpfr.id = (
    (
      SELECT
        pricing_flat_rates.id
      FROM
        pricing_flat_rates
      WHERE
        pricing_flat_rates.flat_ratable_type :: text = 'Site' :: text
        AND pricing_flat_rates.flat_ratable_id = drive_grouped.site_id
        AND pricing_flat_rates.active = true
        AND pricing_flat_rates.rate_type :: text = 'travel_expense' :: text
        AND pricing_flat_rates.valid_from <= drive_grouped.start
      ORDER BY
        pricing_flat_rates.valid_from DESC
      limit
        1
    )
  )
WHERE
  t.discarded_at IS NULL
ORDER BY
    "start" DESC
