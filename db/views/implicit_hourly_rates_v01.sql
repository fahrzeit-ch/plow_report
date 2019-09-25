SELECT q1.hourly_rate_id,
    q1.price_cents,
    q1.price_currency,
    q1.activity_id,
    q1.customer_id,
    q1.company_id,
    q1.rate_type,
    q1.inheritance_type,
    q1.inheritance_level
   FROM ( SELECT hr.id AS hourly_rate_id,
            hr.price_cents,
            hr.price_currency,
            hr.company_id,
            ca.activity_id,
            ca.customer_id,
                CASE
                    WHEN hr.customer_id IS NOT NULL AND hr.activity_id IS NOT NULL THEN 'customer_activity_rate'::text
                    WHEN hr.customer_id IS NOT NULL AND hr.activity_id IS NULL THEN 'customer_base_rate'::text
                    WHEN hr.customer_id IS NULL AND hr.activity_id IS NOT NULL THEN 'activity_rate'::text
                    WHEN hr.customer_id IS NULL AND hr.activity_id IS NULL THEN 'base_rate'::text
                    ELSE NULL::text
                END AS rate_type,
                CASE
                    WHEN hr.customer_id = ca.customer_id AND hr.activity_id = ca.activity_id THEN 0
                    when hr.customer_id = ca.customer_id AND hr.activity_id is NULL AND ca.activity_id is NOT NULL THEN 1
                    WHEN hr.customer_id IS NULL AND hr.activity_id IS NOT NULL THEN 2
                    WHEN hr.customer_id IS NULL AND hr.activity_id IS NULL THEN 3
                    ELSE null::integer
                END AS inheritance_level,
                CASE
                    WHEN hr.customer_id = ca.customer_id AND hr.activity_id = ca.activity_id THEN 'explicit'::text
                    ELSE 'inherited'::text
                END AS inheritance_type
           FROM ( SELECT customers.id AS customer_id,
                    activities.id AS activity_id,
                    customers.company_id
                   FROM customers,
                    activities
                  WHERE customers.company_id = activities.company_id
                  ORDER BY customers.id, activities.id) ca,
            hourly_rates hr
          WHERE (hr.activity_id = ca.activity_id OR hr.activity_id IS NULL) AND (hr.customer_id = ca.customer_id OR hr.customer_id IS NULL) AND hr.company_id = ca.company_id) q1
UNION
 SELECT q2.id AS hourly_rate_id,
    q2.price_cents,
    q2.price_currency,
    q2.activity_id,
    q2.customer_id,
    q2.company_id,
    q2.rate_type,
    q2.inheritance_type,
    q2.inheritance_level
   FROM ( SELECT hr.id,
            hr.price_cents,
            hr.price_currency,
            hr.company_id,
            ca.id AS activity_id,
            hr.customer_id,
                CASE
                    WHEN hr.customer_id IS NULL AND hr.activity_id IS NOT NULL THEN 'activity_rate'::text
                    WHEN hr.customer_id IS NULL AND hr.activity_id IS NULL THEN 'base_rate'::text
                    ELSE NULL::text
                END AS rate_type,
                CASE
                    WHEN hr.customer_id IS NULL AND hr.activity_id IS NOT NULL THEN 0
                    WHEN hr.customer_id IS NULL AND hr.activity_id IS NULL THEN 1
                    ELSE null::integer
                END AS inheritance_level,
                CASE
                    WHEN hr.customer_id IS NULL AND hr.activity_id = ca.id THEN 'explicit'::text
                    ELSE 'inherited'::text
                END AS inheritance_type
           FROM activities ca,
            hourly_rates hr
          WHERE (hr.activity_id = ca.id OR hr.activity_id IS NULL) AND hr.company_id = ca.company_id AND hr.customer_id IS NULL) q2