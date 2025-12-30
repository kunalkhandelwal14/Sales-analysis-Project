-- =========================
-- SALES PERFORMANCE ANALYSIS
-- =========================

-- TABLE STRUCTURE
CREATE TABLE sales (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id VARCHAR(15) NOT NULL,
    product VARCHAR(50),
    product_category VARCHAR(50),
    region VARCHAR(50),
    quantity INT CHECK (quantity > 0),
    unit_price DECIMAL(10,2),
    total_sales DECIMAL(10,2)
);

-- =========================
-- KEY PERFORMANCE INDICATORS
-- =========================

-- Total Revenue
SELECT SUM(total_sales) AS total_revenue
FROM sales;

-- Total Orders
SELECT COUNT(order_id) AS total_orders
FROM sales;

-- Average Order Value
SELECT ROUND(SUM(total_sales) / COUNT(order_id), 2) AS average_order_value
FROM sales;

-- =========================
-- TIME-BASED ANALYSIS
-- =========================

-- Monthly Sales Trend
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(total_sales) AS monthly_sales
FROM sales
GROUP BY year, month
ORDER BY year, month;

-- =========================
-- REGIONAL & PRODUCT ANALYSIS
-- =========================

-- Sales by Region
SELECT 
    region,
    SUM(total_sales) AS region_sales
FROM sales
GROUP BY region
ORDER BY region_sales DESC;

-- Top 5 Products by Revenue
SELECT product,
    SUM(total_sales) AS product_revenue
FROM sales
GROUP BY product
ORDER BY product_revenue DESC
LIMIT 5;

-- Category-wise Sales
SELECT 
    product_category,
    SUM(total_sales) AS category_revenue
FROM sales
GROUP BY product_category
ORDER BY category_revenue DESC;

-- =========================
-- CUSTOMER ANALYSIS
-- =========================

-- MORE FREQUENT ORDERING CUSTOMERS
SELECT 
    customer_id,
    COUNT(*) AS total_orders
FROM sales
GROUP BY customer_id
HAVING count(*) >3
ORDER BY total_orders DESC;

-- =========================
-- ADVANCED ANALYSIS
-- =========================

-- Products with Sales Above Overall Average
WITH product_total AS (
    SELECT 
        product,
        SUM(total_sales) AS total_revenue
    FROM sales
    GROUP BY product
)
SELECT 
    product,
   total_revenue
FROM product_total
WHERE total_revenue > (SELECT AVG(total_revenue) FROM product_total);

-- Monthly Growth Analysis
WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS year,
        EXTRACT(MONTH FROM order_date) AS month,
        SUM(total_sales) AS month_sales
    FROM sales
    GROUP BY year, month
)
SELECT 
    year,
    month,
    month_sales,
    LAG(month_sales) OVER (ORDER BY year, month) AS previous_month_sales,
    ROUND(
        (month_sales - LAG(month_sales) OVER (ORDER BY year, month))
        / LAG(month_sales) OVER (ORDER BY year, month) * 100, 2
    ) AS monthly_growth_percentage
FROM monthly_sales
ORDER BY year, month;
