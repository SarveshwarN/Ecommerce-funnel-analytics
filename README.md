# Ecommerce-funnel-analytics

## Title

**E-commerce Funnel & Revenue Analytics using Microsoft Fabric and Power BI**

---

## Executive Summary

This project presents an end-to-end **business analytics dashboard** built on curated Gold data in **Microsoft Fabric**, with analysis and visualization delivered through **Power BI**.

The dashboard focuses on:

* Executive KPIs (Revenue, Orders, AOV)
* Funnel conversion and leakage analysis
* Revenue stability and attribution assessment

A key outcome of the analysis was identifying a **major funnel leakage point** and uncovering a **data attribution limitation** that impacts product-level decision-making.
All insights are derived using **SQL-driven analysis** and visualized in a **3-page Power BI dashboard** designed for executive and stakeholder consumption.

---

## Business Problem

An e-commerce platform needs to understand:

1. How overall revenue and orders are trending over time
2. Where users drop off in the purchase funnel
3. Whether revenue performance is driven by traffic, conversion, or order value
4. Whether product-level revenue attribution is reliable for merchandising decisions

Without clear answers to these questions, growth initiatives risk focusing on the wrong levers (e.g., acquisition instead of conversion).

---

## Methodology

The analysis followed a **business-first analytics approach**, using only curated Gold tables.

### Data Source

* Microsoft Fabric Lakehouse (Gold layer)
* Tables used:

  * `gold.daily_kpis`
  * `gold.funnel_summary_daily`
  * `gold.product_sales_daily`

### Analytical Approach

1. **SQL-based EDA**

   * Date coverage and KPI sanity checks
   * Funnel volume validation
2. **Funnel Analysis**

   * Session-level funnel stages
   * Conversion rates between stages
   * Identification of the largest leakage point
3. **KPI Trend Analysis**

   * Revenue, Orders, and AOV trends
   * Best and worst performing days
4. **Revenue Attribution Assessment**

   * Validation of product-level revenue mapping
   * Shift to revenue stability and temporal concentration analysis due to attribution gaps
5. **Visualization**

   * Interactive Power BI dashboard with slicers and cross-filtering
   * Executive-friendly layout and annotations

No pipeline, Spark, or engineering logic is modified or discussed as part of this analysis.

---

## Skills

**Technical Skills**

* Power BI (Data Modeling, DAX, Interactive Dashboards)
* SQL (EDA, aggregations, window functions, funnel logic)
* Microsoft Fabric (Lakehouse, Semantic Models)

**Analytical Skills**

* Funnel analysis & conversion diagnostics
* KPI trend analysis
* Revenue driver identification
* Data quality assessment
* Business storytelling with dashboards

---

## Results & Business Recommendation

### Key Findings

* The **largest funnel leakage** occurs between **Add to Cart → Checkout**, with ~45% of high-intent sessions dropping off.
* Revenue fluctuations are more closely tied to **conversion rate changes** than traffic volume.
* A significant share of revenue is concentrated on **peak days**, indicating reliance on campaign or spike performance.
* **100% of purchase revenue lacks product-level attribution**, making product and category analysis unreliable.

---


### Business Recommendations

1. Prioritize **checkout friction reduction** (guest checkout, cost transparency, payment UX).
2. Treat **conversion rate** as a primary performance KPI alongside revenue.
3. Improve **event instrumentation** to ensure purchase events carry product identifiers.
4. Strengthen baseline conversion to reduce dependency on peak-day revenue spikes.

---
## Dashboard
<img width="2000" height="1140" alt="image" src="https://github.com/user-attachments/assets/eea11bfa-5bef-42cb-8cda-7a2d2db5d436" />

---

<img width="2000" height="1140" alt="image" src="https://github.com/user-attachments/assets/70959624-7ab5-4b42-b2f6-35cc5411a20b" />



## Next Steps

If product attribution is resolved, future analysis can include:

* Product and category-level revenue contribution
* Pareto analysis on products and categories
* Inventory and merchandising optimization insights

Additional enhancements:

* Device-level funnel analysis
* Campaign overlay on revenue and conversion trends
* Cohort-based repeat purchase analysis

---


