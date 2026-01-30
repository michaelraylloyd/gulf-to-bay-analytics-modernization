# Business Metrics Catalog

The Business Metrics Catalog defines the governed, business‑aligned measures used across the Semantic Model. These metrics provide consistent, reusable calculations for dashboards, reports, and analytical workflows. This catalog ensures that all consumers interpret KPIs and performance indicators in the same way.

---

## Purpose

This catalog provides:

- A single source of truth for business metrics  
- Clear definitions and calculation logic  
- Consistent usage across BI tools  
- Governance and auditability  
- Alignment with curated Gold‑layer data  

These metrics form the analytical backbone of the organization.

---

## Revenue Metrics

### **Total Revenue**
**Definition:** Sum of `total_amount` across all sales.  
**Formula:** `SUM(total_amount)`  
**Purpose:** Measures gross sales performance.

### **Average Order Value (AOV)**
**Definition:** Average revenue per sale transaction.  
**Formula:** `SUM(total_amount) / COUNT(sale_id)`  
**Purpose:** Indicates customer purchasing behavior.

### **Revenue per Customer**
**Definition:** Total revenue divided by distinct customers.  
**Formula:** `SUM(total_amount) / COUNT(DISTINCT customer_id)`  
**Purpose:** Measures customer value and engagement.

---

## Quantity Metrics

### **Total Quantity Sold**
**Definition:** Sum of units sold across all transactions.  
**Formula:** `SUM(quantity)`  
**Purpose:** Measures product movement and demand.

### **Average Quantity per Order**
**Definition:** Average number of units per sale.  
**Formula:** `SUM(quantity) / COUNT(sale_id)`  
**Purpose:** Indicates order composition and buying patterns.

---

## Margin Metrics

### **Gross Margin**
**Definition:** Revenue minus cost of goods sold.  
**Formula:** `SUM(total_amount) - SUM(quantity * unit_cost)`  
**Purpose:** Measures profitability at the transaction level.

### **Gross Margin Percentage**
**Definition:** Gross margin as a percentage of revenue.  
**Formula:** `(Gross Margin) / SUM(total_amount)`  
**Purpose:** Indicates profitability efficiency.

---

## Customer Metrics

### **Customer Count**
**Definition:** Number of distinct customers in the selected period.  
**Formula:** `COUNT(DISTINCT customer_id)`  
**Purpose:** Measures customer base size.

### **New Customers**
**Definition:** Customers with their first purchase in the selected period.  
**Formula:** Derived from customer first‑purchase date.  
**Purpose:** Measures acquisition effectiveness.

### **Repeat Customers**
**Definition:** Customers with more than one purchase.  
**Formula:** `COUNT(customer_id HAVING COUNT(sale_id) > 1)`  
**Purpose:** Measures retention and loyalty.

---

## Product Metrics

### **Top‑Selling Products**
**Definition:** Products ranked by total quantity sold.  
**Formula:** `SUM(quantity)` grouped by product.  
**Purpose:** Identifies high‑performing SKUs.

### **Product Revenue Contribution**
**Definition:** Percentage of total revenue contributed by each product.  
**Formula:** `SUM(total_amount) / SUM(total_amount across all products)`  
**Purpose:** Measures product portfolio performance.

---

## Time‑Based Metrics

### **Daily Revenue**
**Definition:** Total revenue aggregated by day.  
**Purpose:** Supports trend analysis and forecasting.

### **Month‑over‑Month Growth**
**Definition:** Percentage change in revenue from one month to the next.  
**Formula:** `(Current Month Revenue - Prior Month Revenue) / Prior Month Revenue`  
**Purpose:** Measures growth momentum.

### **Year‑to‑Date Revenue**
**Definition:** Cumulative revenue from the start of the year.  
**Purpose:** Tracks annual performance.

---

## Governance Notes

- All metrics must be defined in the Semantic Model, not in individual reports.  
- Metric definitions must not be duplicated or re‑implemented downstream.  
- Changes to metric logic require versioning and documentation updates.  
- All dashboards must reference these governed measures.  

---

## Summary

The Business Metrics Catalog provides the authoritative definitions for all analytical measures used across the organization. It ensures consistency, clarity, and trust in every dashboard and report built on the Lakehouse.