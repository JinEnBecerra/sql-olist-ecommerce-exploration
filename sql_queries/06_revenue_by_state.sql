/*
Question: Which states generate the most revenue?
Tables: orders, order_payments, customers

Logic:
- Filter orders where order_status = 'delivered'
- Join customers to get customer_state
- Join order_payments to get payment_value
- SUM(payment_value) grouped by state
- ORDER BY revenue DESC

Data Quality Check:
Verified no orphaned orders (orders without matching customers) before JOIN.
Safe to use INNER JOIN without data loss.
*/

WITH order_revenue AS (
    SELECT
        order_id,
        SUM(payment_value) AS revenue
    FROM order_payments
    GROUP BY order_id
)

SELECT
    c.customer_state AS state,
    SUM(r.revenue) AS revenue
FROM orders o
INNER JOIN order_revenue r ON o.order_id = r.order_id
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE
    o.order_status = 'delivered'
GROUP BY
    c.customer_state
ORDER BY
    revenue DESC;
