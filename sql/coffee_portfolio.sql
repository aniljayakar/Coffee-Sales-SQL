-- ============================================================================
-- Coffee Sales SQL Portfolio Project
-- Analyst-focused SQL analysis using the orders, customers, and products tables.
-- Dialect: PostgreSQL-compatible SQL
-- ============================================================================


-- ============================================================================
-- 1. Basic Filtering and Aggregation
-- ============================================================================

-- Business question: What is the overall sales footprint across orders, customers, units, and revenue?
-- Grain: One row for the full business.
-- Key idea: Aggregate core KPIs after joining order lines to product pricing.
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS active_customers,
    SUM(o.quantity) AS total_units_sold,
    ROUND(SUM(o.quantity * p.unit_price), 2) AS total_revenue
FROM orders AS o
JOIN products AS p
    ON p.product_id = o.product_id;


-- Business question: How large is the product catalog by coffee type and roast type?
-- Grain: One row per coffee type and roast type combination.
-- Key idea: Group product rows and summarize pricing and profit metrics.
SELECT
    p.coffee_type,
    p.roast_type,
    COUNT(*) AS product_count,
    ROUND(AVG(p.unit_price), 2) AS avg_unit_price,
    ROUND(AVG(p.profit), 2) AS avg_unit_profit
FROM products AS p
GROUP BY
    p.coffee_type,
    p.roast_type
ORDER BY
    p.coffee_type,
    p.roast_type;


-- Business question: Which individual products drive the most volume and revenue?
-- Grain: One row per product.
-- Key idea: Join orders to products and rank by aggregated sales output.
SELECT
    p.product_id,
    p.coffee_type,
    p.roast_type,
    p.size,
    SUM(o.quantity) AS total_units_sold,
    ROUND(SUM(o.quantity * p.unit_price), 2) AS total_revenue
FROM orders AS o
JOIN products AS p
    ON p.product_id = o.product_id
GROUP BY
    p.product_id,
    p.coffee_type,
    p.roast_type,
    p.size
ORDER BY
    total_units_sold DESC,
    total_revenue DESC,
    p.product_id
LIMIT 10;


-- ============================================================================
-- 2. Conditional Logic and Segmentation
-- ============================================================================

-- Business question: Which coffee types fall into high, medium, or low revenue tiers?
-- Grain: One row per coffee type.
-- Key idea: Use CASE logic on aggregated revenue to create business segments.
SELECT
    p.coffee_type,
    ROUND(SUM(o.quantity * p.unit_price), 2) AS total_revenue,
    CASE
        WHEN SUM(o.quantity * p.unit_price) >= 12000 THEN 'High Revenue'
        WHEN SUM(o.quantity * p.unit_price) >= 9000 THEN 'Medium Revenue'
        ELSE 'Low Revenue'
    END AS revenue_tier
FROM orders AS o
JOIN products AS p
    ON p.product_id = o.product_id
GROUP BY
    p.coffee_type
ORDER BY
    total_revenue DESC,
    p.coffee_type;


-- Business question: How is each coffee type distributed across price bands?
-- Grain: One row per coffee type.
-- Key idea: Use conditional aggregation to count products in each price segment.
SELECT
    p.coffee_type,
    COUNT(*) AS total_products,
    SUM(CASE WHEN p.unit_price > 15 THEN 1 ELSE 0 END) AS premium_products,
    SUM(CASE WHEN p.unit_price BETWEEN 10 AND 15 THEN 1 ELSE 0 END) AS mid_tier_products,
    SUM(CASE WHEN p.unit_price < 10 THEN 1 ELSE 0 END) AS entry_products,
    ROUND(
        100.0 * SUM(CASE WHEN p.unit_price > 15 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS pct_premium_products
FROM products AS p
GROUP BY
    p.coffee_type
ORDER BY
    pct_premium_products DESC,
    p.coffee_type;


-- Business question: How do loyalty and non-loyalty customers compare on volume and revenue?
-- Grain: One row per loyalty card segment.
-- Key idea: Segment customer orders with CASE-style grouping already stored in the dimension.
SELECT
    c.loyalty_card,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.quantity) AS total_units_sold,
    ROUND(SUM(o.quantity * p.unit_price), 2) AS total_revenue,
    ROUND(
        SUM(o.quantity * p.unit_price) / COUNT(DISTINCT o.order_id),
        2
    ) AS avg_revenue_per_order
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
JOIN products AS p
    ON p.product_id = o.product_id
GROUP BY
    c.loyalty_card
ORDER BY
    total_revenue DESC,
    c.loyalty_card;


-- ============================================================================
-- 3. Join-Based Analysis
-- ============================================================================

-- Business question: Who are the highest-value customers by total spend?
-- Grain: One row per customer.
-- Key idea: Join all three tables to combine customer attributes with sales revenue.
SELECT
    c.customer_id,
    c.customer_name,
    c.country,
    c.loyalty_card,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.quantity * p.unit_price), 2) AS total_revenue
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
JOIN products AS p
    ON p.product_id = o.product_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.country,
    c.loyalty_card
ORDER BY
    total_revenue DESC,
    total_orders DESC,
    c.customer_id
LIMIT 10;


-- Business question: Which coffee types generate the most revenue within each country?
-- Grain: One row per country and coffee type.
-- Key idea: Roll up joined order activity across geography and product category.
SELECT
    c.country,
    p.coffee_type,
    SUM(o.quantity) AS total_units_sold,
    ROUND(SUM(o.quantity * p.unit_price), 2) AS total_revenue
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
JOIN products AS p
    ON p.product_id = o.product_id
GROUP BY
    c.country,
    p.coffee_type
ORDER BY
    c.country,
    total_revenue DESC,
    p.coffee_type;


-- Business question: Which products exist in the catalog but have never been sold?
-- Grain: One row per unsold product.
-- Key idea: Use a LEFT JOIN and null filter to isolate unmatched products.
SELECT
    p.product_id,
    p.coffee_type,
    p.roast_type,
    p.size
FROM products AS p
LEFT JOIN orders AS o
    ON o.product_id = p.product_id
WHERE o.order_id IS NULL
ORDER BY
    p.product_id;


-- ============================================================================
-- 4. Subqueries and CTEs
-- ============================================================================

-- Business question: Which customers spend more than the average customer overall?
-- Grain: One row per above-average customer.
-- Key idea: Calculate customer revenue in a CTE and compare it to a scalar subquery benchmark.
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.country,
        SUM(o.quantity * p.unit_price) AS total_revenue
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.country
)
SELECT
    customer_id,
    customer_name,
    country,
    ROUND(total_revenue, 2) AS total_revenue
FROM customer_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM customer_revenue
)
ORDER BY
    total_revenue DESC,
    customer_id;


-- Business question: Which customers outperform the average customer in their own country?
-- Grain: One row per above-country-average customer.
-- Key idea: Build a customer revenue CTE and benchmark within-country averages.
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.country,
        SUM(o.quantity * p.unit_price) AS total_revenue
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.country
),
benchmarked_customers AS (
    SELECT
        customer_id,
        customer_name,
        country,
        total_revenue,
        AVG(total_revenue) OVER (PARTITION BY country) AS avg_country_customer_revenue
    FROM customer_revenue
)
SELECT
    customer_id,
    customer_name,
    country,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(avg_country_customer_revenue, 2) AS avg_country_customer_revenue
FROM benchmarked_customers
WHERE total_revenue > avg_country_customer_revenue
ORDER BY
    country,
    total_revenue DESC,
    customer_id;


-- Business question: Which customers have never placed an order?
-- Grain: One row per inactive customer.
-- Key idea: Use NOT EXISTS to isolate customers with no matching order activity.
SELECT
    c.customer_id,
    c.customer_name,
    c.country
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
)
ORDER BY
    c.country,
    c.customer_name,
    c.customer_id;


-- ============================================================================
-- 5. Window Functions and Ranking
-- ============================================================================

-- Business question: How does each customer rank by total revenue under different ranking rules?
-- Grain: One row per customer.
-- Key idea: Use ROW_NUMBER, RANK, and DENSE_RANK on customer revenue totals.
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.country,
        SUM(o.quantity * p.unit_price) AS total_revenue
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.country
)
SELECT
    customer_id,
    customer_name,
    country,
    ROUND(total_revenue, 2) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC, customer_id) AS row_num,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS dense_revenue_rank
FROM customer_revenue
ORDER BY
    total_revenue DESC,
    customer_id;


-- Business question: What is the top-selling product within each coffee type?
-- Grain: One row per coffee type.
-- Key idea: Rank products inside each coffee category and keep the top row.
WITH product_sales AS (
    SELECT
        p.coffee_type,
        p.product_id,
        p.roast_type,
        p.size,
        SUM(o.quantity) AS total_units_sold
    FROM orders AS o
    JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY
        p.coffee_type,
        p.product_id,
        p.roast_type,
        p.size
),
ranked_products AS (
    SELECT
        coffee_type,
        product_id,
        roast_type,
        size,
        total_units_sold,
        ROW_NUMBER() OVER (
            PARTITION BY coffee_type
            ORDER BY total_units_sold DESC, product_id
        ) AS sales_rank
    FROM product_sales
)
SELECT
    coffee_type,
    product_id,
    roast_type,
    size,
    total_units_sold
FROM ranked_products
WHERE sales_rank = 1
ORDER BY
    coffee_type;


-- Business question: Who are the top three customers by revenue within each country, including ties?
-- Grain: One row per ranked customer within country.
-- Key idea: Use DENSE_RANK to preserve ties inside each country partition.
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.country,
        SUM(o.quantity * p.unit_price) AS total_revenue
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.country
),
ranked_customers AS (
    SELECT
        customer_id,
        customer_name,
        country,
        total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)
SELECT
    customer_id,
    customer_name,
    country,
    ROUND(total_revenue, 2) AS total_revenue,
    revenue_rank
FROM ranked_customers
WHERE revenue_rank <= 3
ORDER BY
    country,
    revenue_rank,
    total_revenue DESC,
    customer_id;


-- ============================================================================
-- 6. Date-Based Analysis
-- ============================================================================

-- Business question: How do orders, units, and revenue trend month by month?
-- Grain: One row per calendar month.
-- Key idea: Use DATE_TRUNC to create a stable monthly reporting key.
SELECT
    DATE_TRUNC('month', o.order_date)::date AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.quantity) AS total_units_sold,
    ROUND(SUM(o.quantity * p.unit_price), 2) AS total_revenue
FROM orders AS o
JOIN products AS p
    ON p.product_id = o.product_id
GROUP BY
    DATE_TRUNC('month', o.order_date)::date
ORDER BY
    order_month;


-- Business question: How is monthly revenue changing over time within each country?
-- Grain: One row per country and calendar month.
-- Key idea: Use LAG to compare each month to the prior month in the same country.
WITH country_monthly_revenue AS (
    SELECT
        c.country,
        DATE_TRUNC('month', o.order_date)::date AS order_month,
        ROUND(SUM(o.quantity * p.unit_price), 2) AS total_revenue
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY
        c.country,
        DATE_TRUNC('month', o.order_date)::date
),
revenue_with_lag AS (
    SELECT
        country,
        order_month,
        total_revenue,
        LAG(total_revenue) OVER (
            PARTITION BY country
            ORDER BY order_month
        ) AS prior_month_revenue
    FROM country_monthly_revenue
)
SELECT
    country,
    order_month,
    total_revenue,
    prior_month_revenue,
    ROUND(total_revenue - prior_month_revenue, 2) AS month_over_month_change
FROM revenue_with_lag
ORDER BY
    country,
    order_month;


-- Business question: When did each customer first buy and most recently buy?
-- Grain: One row per customer.
-- Key idea: Use MIN and MAX over joined order history.
SELECT
    c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS latest_order_date
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY
    latest_order_date DESC,
    c.customer_id;


-- ============================================================================
-- 7. Set Operations and Self Joins
-- ============================================================================

-- Business question: What distinct customer grouping values exist for country and loyalty status?
-- Grain: One row per distinct grouping value.
-- Key idea: Stack two labeled result sets with UNION ALL.
(SELECT DISTINCT
    'country' AS group_type,
    c.country AS group_value
FROM customers AS c)
UNION ALL
(SELECT DISTINCT
    'loyalty_card' AS group_type,
    c.loyalty_card AS group_value
FROM customers AS c)
ORDER BY
    group_type,
    group_value;


-- Business question: Which customer pairs come from the same country?
-- Grain: One row per unique customer pair within country.
-- Key idea: Self join customers and use an ordered ID condition to avoid duplicate pairs.
SELECT
    c1.country,
    c1.customer_name AS customer_1,
    c2.customer_name AS customer_2
FROM customers AS c1
JOIN customers AS c2
    ON c1.country = c2.country
   AND c1.customer_id < c2.customer_id
ORDER BY
    c1.country,
    c1.customer_name,
    c2.customer_name;


-- Business question: Which product pairs share a coffee type but differ in roast profile?
-- Grain: One row per unique product pair.
-- Key idea: Self join products within coffee type and filter to different roasts.
SELECT
    p1.coffee_type,
    p1.product_id AS product_1_id,
    p1.roast_type AS product_1_roast,
    p2.product_id AS product_2_id,
    p2.roast_type AS product_2_roast
FROM products AS p1
JOIN products AS p2
    ON p1.coffee_type = p2.coffee_type
   AND p1.roast_type <> p2.roast_type
   AND p1.product_id < p2.product_id
ORDER BY
    p1.coffee_type,
    p1.product_id,
    p2.product_id;


-- ============================================================================
-- 8. Final Analyst-Style Business Questions
-- ============================================================================

-- Business question: Which coffee type is the top revenue driver in each country?
-- Grain: One row per winning coffee type within country, including ties.
-- Key idea: Aggregate country-category revenue and rank within each country.
WITH coffee_country_revenue AS (
    SELECT
        c.country,
        p.coffee_type,
        SUM(o.quantity * p.unit_price) AS total_revenue
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY
        c.country,
        p.coffee_type
),
ranked_coffee AS (
    SELECT
        country,
        coffee_type,
        total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM coffee_country_revenue
)
SELECT
    country,
    coffee_type,
    ROUND(total_revenue, 2) AS total_revenue
FROM ranked_coffee
WHERE revenue_rank = 1
ORDER BY
    country,
    total_revenue DESC,
    coffee_type;


-- Business question: In which countries do loyalty-card customers outspend non-loyalty customers?
-- Grain: One row per qualifying country.
-- Key idea: Pivot segment revenue with conditional sums and filter in HAVING.
SELECT
    c.country,
    ROUND(
        SUM(CASE WHEN c.loyalty_card = 'Yes' THEN o.quantity * p.unit_price ELSE 0 END),
        2
    ) AS loyalty_revenue,
    ROUND(
        SUM(CASE WHEN c.loyalty_card = 'No' THEN o.quantity * p.unit_price ELSE 0 END),
        2
    ) AS non_loyalty_revenue,
    ROUND(
        SUM(CASE WHEN c.loyalty_card = 'Yes' THEN o.quantity * p.unit_price ELSE 0 END)
        - SUM(CASE WHEN c.loyalty_card = 'No' THEN o.quantity * p.unit_price ELSE 0 END),
        2
    ) AS revenue_gap
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
JOIN products AS p
    ON p.product_id = o.product_id
GROUP BY
    c.country
HAVING
    SUM(CASE WHEN c.loyalty_card = 'Yes' THEN o.quantity * p.unit_price ELSE 0 END)
    > SUM(CASE WHEN c.loyalty_card = 'No' THEN o.quantity * p.unit_price ELSE 0 END)
ORDER BY
    revenue_gap DESC,
    c.country;


-- Business question: What was the strongest revenue month for each country?
-- Grain: One row per country-month winner, including ties.
-- Key idea: Build monthly revenue, then rank each country's months by total revenue.
WITH country_monthly_revenue AS (
    SELECT
        c.country,
        DATE_TRUNC('month', o.order_date)::date AS order_month,
        SUM(o.quantity * p.unit_price) AS total_revenue
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY
        c.country,
        DATE_TRUNC('month', o.order_date)::date
),
ranked_months AS (
    SELECT
        country,
        order_month,
        total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM country_monthly_revenue
)
SELECT
    country,
    order_month,
    ROUND(total_revenue, 2) AS total_revenue
FROM ranked_months
WHERE revenue_rank = 1
ORDER BY
    country,
    order_month;


-- Business question: Which non-loyalty customers still outperform their country average on revenue?
-- Grain: One row per qualifying customer.
-- Key idea: Compare customer revenue to a country benchmark after segmenting loyalty status.
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.country,
        c.loyalty_card,
        SUM(o.quantity * p.unit_price) AS total_revenue
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN products AS p
        ON p.product_id = o.product_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.country,
        c.loyalty_card
),
benchmarked_customers AS (
    SELECT
        customer_id,
        customer_name,
        country,
        loyalty_card,
        total_revenue,
        AVG(total_revenue) OVER (PARTITION BY country) AS avg_country_customer_revenue
    FROM customer_revenue
)
SELECT
    country,
    customer_id,
    customer_name,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(avg_country_customer_revenue, 2) AS avg_country_customer_revenue
FROM benchmarked_customers
WHERE loyalty_card = 'No'
  AND total_revenue > avg_country_customer_revenue
ORDER BY
    country,
    total_revenue DESC,
    customer_id;
