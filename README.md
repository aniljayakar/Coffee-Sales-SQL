# Coffee Sales SQL Case Study

## Project Overview
This project analyzes a coffee sales dataset using SQL in pgAdmin to answer analyst-style business questions across customer performance, product mix, loyalty behavior, and monthly revenue trends.

The goal was not just to write SQL queries, but to structure the analysis the way a business analyst would: define the correct grain, choose the right tables, calculate meaningful metrics, and interpret the results in a business context.

This repository presents the work as a portfolio project rather than a practice notebook. The SQL script is cleaned and organized into sections covering foundational analysis, segmentation, ranking, time-based trends, and business-facing reporting questions.

## Dataset Overview
The dataset contains transactional coffee sales data across three related tables:

- `orders`: purchase activity at the order level
- `customers`: customer attributes, location, and loyalty status
- `products`: coffee product attributes, pricing, and profit

Together, these tables support analysis by customer, country, coffee type, roast type, and time period.

## Table Schema Summary

### `orders`
- `order_id`
- `order_date`
- `customer_id`
- `product_id`
- `quantity`

### `customers`
- `customer_id`
- `customer_name`
- `email`
- `phone_number`
- `address_line1`
- `city`
- `country`
- `postcode`
- `loyalty_card`

### `products`
- `product_id`
- `coffee_type`
- `roast_type`
- `size`
- `unit_price`
- `price_per_100g`
- `profit`

## SQL Concepts Demonstrated
- Filtering and aggregation
- `GROUP BY` and `HAVING`
- Conditional logic with `CASE WHEN`
- Multi-table joins
- Anti-join and membership patterns
- Correlated subqueries
- Common table expressions (CTEs)
- Window functions
- `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`
- Date-based analysis and monthly rollups
- `UNION` / `UNION ALL`
- Self joins
- KPI and business metric development

## Business Questions Answered
- Which customers generate the highest total revenue?
- How does revenue differ between loyalty and non-loyalty customers?
- Which coffee types perform best in each country?
- How does monthly revenue change over time?
- Which customers outperform their country-level average revenue?
- Which products or customers have no order activity?
- What is the strongest revenue month in each country?
- How do product mix and customer value vary across markets?

## Key Findings
A few headline findings from the analysis:

- Revenue was concentrated among a relatively small number of high-value customers.
- Non-loyalty customers generated higher total revenue overall than loyalty customers in this dataset.
- Coffee type performance varied by country, suggesting differences in market preference.
- Monthly revenue showed noticeable fluctuations over time rather than a flat sales pattern.
- Ranking and benchmark queries helped identify top performers, inactive entities, and customers outperforming their local market average.

## Repository Structure
```text
coffee-sales-sql-case-study/
├── README.md
├── sql/
│   └── coffee_portfolio.sql
├── data/
│   ├── customers.csv
│   ├── orders.csv
│   └── products.csv
├── images/
│   ├── 01_top_10_customers_by_revenue.png
│   ├── 02_revenue_per_coffee_type_per_country.png
│   ├── 03_monthly_revenue_change.png
│   └── 04_loyalty_vs_non_loyalty_performance.png
└── docs/
    └── results_summary.md
