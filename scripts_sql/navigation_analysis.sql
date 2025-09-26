-- 3. Month-over-Month Growth
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(sale_date, '%Y-%m') as sale_month,
        SUM(amount_rwf) as monthly_revenue
    FROM sales
    GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
)
SELECT 
    sale_month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY sale_month) as previous_month_revenue,
    ROUND(((monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY sale_month)) 
          / LAG(monthly_revenue) OVER (ORDER BY sale_month)) * 100, 2) as growth_percentage
FROM monthly_sales
ORDER BY sale_month;
