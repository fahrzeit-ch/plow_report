select date_trunc('day', start_time), name, sum(number_of_drives) nr_of_drives, count(*) as nr_of_tours, company_id
from (
         SELECT
             c.name,
             t2.start_time,
             count(distinct d.site_id) AS number_of_drives,
             c.id as company_id
         FROM drives d
                  JOIN drivers dr ON dr.id = d.driver_id
                  JOIN companies c ON dr.company_id = c.id
                  JOIN tours t2 ON d.tour_id = t2.id AND t2.discarded_at IS NULL
         WHERE d.discarded_at IS NULL
         GROUP BY c.name, c.id, t2.start_time, t2.id
         order by c.name, t2.start_time
     ) tours_report
group by name, company_id, date_trunc('day', start_time);