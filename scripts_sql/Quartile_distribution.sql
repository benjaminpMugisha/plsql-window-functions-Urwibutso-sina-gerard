-- 4. Customer Spending Quartiles
SELECT
    customer_name,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) as spending_quartile
FROM (
    SELECT
        c.name as customer_name,
        SUM(s.amount_rwf) as total_spent
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    GROUP BY c.name
) customer_totals
ORDER BY spending_quartile, total_spent DESC;
