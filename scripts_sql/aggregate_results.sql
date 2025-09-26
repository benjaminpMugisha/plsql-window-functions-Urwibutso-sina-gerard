
-- 2. Running Monthly Total
SELECT 
    DATE_FORMAT(sale_date, '%Y-%m') as sale_month,
    SUM(amount_rwf) as monthly_revenue,
    SUM(SUM(amount_rwf)) OVER (ORDER BY DATE_FORMAT(sale_date, '%Y-%m')) as running_total
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY sale_month;
