/*
Question: Is there a correlation between delivery time and customer review scores?
Tables: orders, order_reviews

Logic:
- Filter orders where order_status = 'delivered'
- Calculate delivery time = order_delivered_customer_date - order_purchase_timestamp
- Join order_reviews on order_id to get review_score
- Group by review_score
- AVG(delivery time) per review score to see the correlation
*/

WITH clean_orders as (
    select
      ore.review_score,
      o.order_purchase_timestamp,
      o.order_delivered_customer_date
    from
      orders o 
      inner join order_reviews ore on o.order_id = ore.order_id
    where
      order_status = 'delivered'
      and NULLIF(o.order_purchase_timestamp, '') is not null
      and NULLIF(o.order_delivered_customer_date, '') is not null
      and ore.review_score is not null
      and o.order_delivered_customer_date::timestamp >= o.order_purchase_timestamp::timestamp
      and order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp <= interval '60 days'
  ),
  avg_delivery_metrics as (
    select
      review_score,
      ROUND(
        AVG(
          DATE_PART(
            'epoch',
            order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp
          ) / 86400
        )::NUMERIC,
        1
      ) as avg_delivery_days
    from
      clean_orders
    group by
      review_score
  )
select
  review_score,
  avg_delivery_days,
  round(avg(avg_delivery_days) over (), 1) as overall_avg,
  round(
    avg_delivery_days - avg(avg_delivery_days) over (),
    1
  ) as diff_from_avg
from
  avg_delivery_metrics
  order by review_score