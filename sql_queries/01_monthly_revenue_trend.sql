-- Question: How has revenue changed over time?
-- Tables used: orders, payments
-- Only analyzing orders that are completed (order_status = 'delivered')


SELECT 
    to_char(order_month, 'YYYY-Mon') AS sorted_order_month, 
    SUM(payment_value) AS monthly_revenue
FROM (
    SELECT 
        date_trunc('month', order_purchase_timestamp::timestamp) AS order_month,
        payment_value 
    FROM orders o
    INNER JOIN order_payments p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
) t
GROUP BY order_month
ORDER BY order_month;





