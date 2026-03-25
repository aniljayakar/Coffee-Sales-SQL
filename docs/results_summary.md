# Results Summary

## Objective
This project uses SQL to analyze a coffee sales dataset across customers, products, countries, and time. The aim was to answer practical business questions and show how SQL can be used in an analyst workflow, from joining tables and building metrics to ranking results and interpreting patterns.

## Key Findings

### 1. A small group of customers drove a large share of revenue
The customer ranking queries showed a clear concentration pattern. A relatively small number of customers sat at the top of the revenue table, while the rest of the customer base contributed much smaller amounts.

This matters because customer value is not spread evenly. If a business depends too heavily on a small group of buyers, retention risk becomes more important. Losing even a few high-value customers could have a noticeable effect on sales.

---

### 2. Non-loyalty customers slightly outperformed loyalty customers on revenue
When I compared loyalty and non-loyalty customers, non-loyalty customers generated slightly more total revenue overall. They also showed a slightly higher average revenue per order in the result set I reviewed.

That does not automatically mean the loyalty program is ineffective. It does mean the program is not clearly linked to stronger revenue performance in this dataset. A business team would need to look deeper at repeat purchase behavior, order frequency, and retention before drawing a stronger conclusion.

---

### 3. Coffee type performance changed by country
Coffee type did not perform the same way in every market. Some coffee types generated more revenue in one country than they did in another, which points to differences in customer preference across regions.

This is useful because it suggests product strategy should not always be treated as one-size-fits-all. If a coffee type performs especially well in one country, that market may respond better to targeted promotions, featured placement, or inventory emphasis for that product.

---

### 4. Revenue moved up and down noticeably over time
The month-over-month revenue analysis showed clear movement rather than a stable pattern. Some months posted strong gains, while others fell back. Using prior-month comparisons made those shifts easier to spot.

That kind of change is worth paying attention to. It could reflect seasonality, marketing activity, uneven demand, or simple randomness in a smaller dataset. Either way, time-based analysis adds context that a single total revenue figure cannot provide.

---

### 5. Most customers had placed at least one order
The customer activity query showed that more than 90 percent of customers in each country had placed at least one order. That is a strong activation signal at face value.

Still, one order is not the same as sustained engagement. A customer who ordered once and never returned would count the same way in this metric as a repeat buyer. That makes this a useful starting point, but not the final word on customer health.

## Recommendations and Next Steps

Because this is a practice dataset, these should be treated as reasonable next steps rather than firm business decisions.

### Look more closely at the top customers
The revenue concentration pattern makes this the clearest next step. I would break the top customers down by country, loyalty status, and number of orders to see whether high revenue comes from repeat purchasing, larger basket sizes, or both.

### Revisit the loyalty analysis with deeper retention metrics
The loyalty comparison is interesting, but it is still a top-level view. The next questions should be about repeat rate, average time between orders, and customer lifespan. That would give a better read on whether loyalty membership affects behavior over time.

### Use country-level product patterns to guide merchandising questions
Since coffee type performance varies across countries, a business team could test whether certain products deserve more attention in specific markets. That might include promotions, stock planning, or a more tailored product mix by region.

### Track monthly movement alongside business events
The monthly revenue shifts suggest that trend analysis could become more useful with context. If promotional calendars, campaigns, or seasonal events were available, I would compare those against the stronger and weaker months to see what lines up.

### Separate customer activation from repeat engagement
The high percentage of customers with at least one order is encouraging, but it does not say much about repeat behavior. The next step would be to split customers into first-time and repeat buyers, then compare their contribution to revenue.

## Why This Project Matters
This project shows more than isolated SQL syntax. It shows the ability to take business questions, map them to the right tables and metrics, and produce results that are easy to interpret.

The work covers joins, aggregations, ranking, segmentation, date analysis, and customer benchmarking. Just as important, it turns those queries into findings and next steps, which is what analysts are expected to do in real work.
