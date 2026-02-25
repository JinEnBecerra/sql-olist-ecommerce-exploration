-- Question: How has revenue changed over time?
-- Tables used: orders, payments
-- Only analyzing orders that are completed (order_status = 'delivered')

SELECT to_char(date_trunc('month', order_purchase_timestamp::timestamp ), 'YYYY-Mon') AS order_month_date, sum(payment_value) AS monthly_revenue
FROM orders o
INNER JOIN order_payments  p
ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1



