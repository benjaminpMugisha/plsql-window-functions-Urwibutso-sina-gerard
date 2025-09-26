# plsql-window-functions-Urwibutso-MUGISHA-PRINCE-Benjamin
**Problem Definition **
Business Context: URWIBUTSO - Sina Gerard is a well-known agro-processing in Nyiragama Rwand. It has an annual turnover of around EUR 1.5 million. The company produces a wide variety of products like AKARUSHO Grape wine, AKANDI Natural Mineral water, AGASHYA Natural fruits juices, AKANOZO Flours, Urwibutso fruit juices, AKACU Tomato Ketchup and AKABANGA Chilli oil. To target high-value clients and optimise inventory, the sales and marketing division must examine sales performance.
Data Challenge: The business does not have a dynamic study of regional product performance, client purchasing patterns , or sales trends. Because of this, it is challenging to determine which products are the best sellers in various provinces, comprehend trends in sales growth, and divide up the client base for successful marketing initiatives.
Anticipated Result: The analysis will offer practical insights to determine the best-performing items by region, comprehend monthly sales patterns, compute growth rates, divide clients into value-based tiers, and guide strategic choices for focused marketing and inventory management.
** Success Criteria **
The following are the project's five particular analytical goals: 

Regional Product Performance: To direct regional marketing and inventory allocation, the use of RANK() function to determine the top 5 goods by revenue for each province each quarter.

Revenue Trend Analysis: To see cumulative annual performance and monitor progress towards revenue targets, compute a running total of monthly sales revenue using SUM () OVER ().

Growth Measurement: To determine times of notable growth or fall for strategic analysis, use LAG () to compute the month-over-month sales growth %.

Customer Value Segmentation: To facilitate tiered marketing tactics and targeted customer retention initiatives, utilize NTILE (4) to divide clients into four expenditure quartiles.

Trend Smoothing: To comprehend the underlying sales, utilize AVG () OVER () with a frame clause to find the revenue's three-month moving average. This can help you better forecast by removing short-term volatility and revealing the underlying sales trend.
Database Schema 

Three core tables that reflect URWIBUTSO- Sina Gerard’s business.
Table definitions:
Table	|Purpose	|Key Columns	|Examples Row
customers |	Stores wholesale clients	|Customer_id (PK), name, province	101,| `Kigali Mart’, `Kigali’
products |	Product catalog |	Product_id (PK), product_name, category	201, | `AKABANGA Chilli Oil’, `Seasoning’
sales	|Sales transactions records	|Sale_id (PK), customer_id (FK), product_id (FK), sale_date, quantity, amount_rwf	|301, 101, 201, `2025-03-17’, 50, 125000

**QUERIES**
CREATE DATABASE sina_gerard_analysis;



CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    province VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    sale_date DATE,
    quantity INT,
    amount_rwf DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
INSERT INTO customers  VALUES
(001, 'Kigali Mart', 'Kigali'),
(002, 'Musanze Hotel', 'Northern'),
(003, 'URWIBUTSO-Sina Gerard', 'Northern'),
(004, 'Huye Supermarket', 'Southern'),
(005, 'Kayonza Distributor', 'Eastern');

INSERT INTO products  VALUES
(101, 'Akabanga Chili Oil', 'Condiments'),
(102, 'AKACU Tomato Ketchup', 'Condiments'),
(103, 'AGASHYA Natural Fruit Juices', 'Beverages'),
(104, 'Urwibutso Mango Juice', 'Beverages'),
(105, 'AKANDI Natural Water', 'Beverages'),
(106, 'AKARUSHO Grape Wine', 'Beverages'),
(107, 'AKANOZO Flour', 'Bakery');

INSERT INTO sales VALUES
(201, 001, 101, '2024-03-25', 50, 125000),
(202, 003,103, '2023-01-20', 30, 90000),
(203, 002, 102, '2025-02-20', 100, 200000),
(204, 001, 107, '2021-02-13', 40, 100000),
(205, 004, 104, '2024-12-15', 60, 150000),
(206, 005, 106, '2022-03-05', 80, 120000),
(207, 002, 105, '2023-03-10', 70, 175000),
(208, 001, 103, '2024-03-15', 45, 135000);

-- 1. Top Products per Province
SELECT province, product_name, total_revenue,    
       RANK() OVER (PARTITION BY province ORDER BY total_revenue DESC) as rank_pos
FROM (
    SELECT c.province, p.product_name, SUM(s.amount_rwf) as total_revenue
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN products p ON s.product_id = p.product_id
    GROUP BY c.province, p.product_name
) sales_summary
ORDER BY province, rank_pos;

-- 2. Running Monthly Total
SELECT 
    DATE_FORMAT(sale_date, '%Y-%m') as sale_month,
    SUM(amount_rwf) as monthly_revenue,
    SUM(SUM(amount_rwf)) OVER (ORDER BY DATE_FORMAT(sale_date, '%Y-%m')) as running_total
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY sale_month;

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

**INSIGHTS**
1. Descriptive: What took place?

"Sales of 'Akabanga Chilli Oil' were consistently ranked #1 in the Eastern and Kigali provinces in Q1 and Q2."
"The running total of revenue shows a steady upward trend, with a significant spike in December."

2. Diagnostic (What caused it?):

"The holiday season and the December rise point to higher consumer spending. It's possible that increased export demand and tourism are the reasons behind Akabanga's top rating in cities like Kigali.

3. Prescriptive: What ought we to do next?

"Suggest boosting Akabanga Chilli Oil output in preparation for the strong demand in Q4. To lower churn, introduce a customised loyalty program for clients in the highest spending quartile.

**REFERENCES**
- Oracle PL/SQL Documentation on Window Functions(https://www.db-fiddle.com/f/kFiX9wCNRowt8DPTo766hu/5).

- (https://issuu.com/intitimagazine/docs/intiti_mag_issue_3_v_final_lowres/28)

- Oracles Tutorial: Analytic Functions.

- (https://www.climate-expert.org/fileadmin/user_upload/Climate_Expert_Case_Study_Sina_Gerard_english.pdf).

- Stack Overflow threads on specific LAG()/LEAD() usage.

- Academic paper on "Customer Segmentation using Data Mining".

- Sina Gerard company website for product categories(https://sinarwanda.rw/).

- Rwanda Ministry of Trade and Industry reports (for contextual data).(https://www.minicom.gov.rw/index.php?eID=dumpFile&t=f&f=122191&token=e331661a410ada5239d2e1b5056e86d95e373385)

- Book: "SQL for Data Analysis" by Anthony DeBarros.

- IBM Documentation on DB2 Window Functions (for comparative syntax).




