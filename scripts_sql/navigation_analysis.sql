-- 3. Month-over-Month Growth
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(sale_date, '%Y-%m') as sale_month,
        SUM(amount_rwf) as monthly_revenue
    FROM sales
    GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
)
