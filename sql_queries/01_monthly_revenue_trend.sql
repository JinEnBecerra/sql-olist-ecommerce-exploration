/*
Question: How has revenue changed over time?
Tables used: orders, payments
Logic: 
- Only analyzing orders that are completed (order_status = 'delivered')
- Cast order_purchase_timestamp to timestamp type
- Inner join order_payments to sum payment values and get total revenue
- Use date_trunc to truncate to month level, then to_char to format for display
- Group and order by the truncated timestamp (not the formatted string) to ensure correct chronological ordering
*/

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





