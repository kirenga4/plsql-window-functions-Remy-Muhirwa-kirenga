# Individual Assignment I: PL/SQL Window Functions

**Course:** Database Development with PL/SQL (INSY 8311)  
**Name:** Muhirwa Kirenga Remy  
**Student ID:** 28368  



## Problem Definition
**Business Context:** Bralirwa, a leading beverage company in Rwanda, sells products across multiple regions.  

**Data Challenge:** Management wants to know the top-selling products per region, track monthly sales trends, and segment customers for better marketing strategies.  

**Expected Outcome:** Using PL/SQL window functions, we rank products, calculate cumulative sales, track month-over-month growth, and classify customers into quartiles.  



## Success Criteria
We implemented the following measurable goals:

1. Top products per region using `RANK()`.  
2. Running monthly totals using `SUM() OVER()`.  
3. Month-over-month sales growth using `LAG()`.  
4. Customer segmentation into quartiles using `NTILE(4)`.  
5. 3-month moving averages using `AVG() OVER()`.  


## Database Schema

 **Customers:** customer_id, name, region  
 **Products:** product_id, name, category  
**Transactions:** transaction_id, customer_id, product_id, sale_date, amount  

**Relationships:**
- Transactions.customer_id → Customers.customer_id  
- Transactions.product_id → Products.product_id  

---

## Queries & Results
### Query 1: Ranking Top Products by Region

 ## Shows top products per region
```sql
Select c.region,p.name AS product_name,SUM(T.amount) AS total_sales,RANK() OVER (PARTITION BY c.region 
ORDER BY SUM(t.amount)DESC) AS product_rank FROM transactions t 
JOIN customers c ON t.customer_id=c.customer_id
JOIN products P ON t.product_id=p.product_id GROUP BY c.region,p.name ORDER BY c.region, total_sales DESC;

-- ScreenShot
![ranking](<screenshots/ranking top products.PNG>)

 -- Query 2: Running Monthly Totals

select TO_CHAR(DATE_TRUNC('month',t.sale_date),'YYYY-MM') AS month,SUM(t.amount) AS monthly_sales,
SUM(SUM(t.amount)) OVER (ORDER BY DATE_TRUNC('month',t.sale_date)) AS running _total 
FROM transactions t GROUP BY DATE_TRUNC('month',t.sale_date) ORDER BY month;

-- ScreenShot
![monthly total](<screenshots/Running Monthly Totals.PNG>)


-- Query 3: Month-over-Month Growth

 WITH monthly AS(SELECT TO_CHAR(DATE_TRUNC('month',sale_date),'YYYY-MM') AS month,SUM(amount) AS Total_sales
 FROM transactions GROUP BY DATE_TRUNC('month',sale_date)) 
 SELECT month,Total_sales,LAG(Total_sales) OVER (ORDER BY month) AS previous_month,(Total_sales - LAG(total_sales) OVER (ORDER BY month)) AS growth 
 FROM monthly ORDER BY month;


-- ScreenShot
![month growth](<screenshots/Month-over-Month Growth.PNG>)


--  Query 4: Customer Quartiles 

 SELECT c.name AS customer_name,SUM(t.amount) AS total_spent,NTILE(4) OVER (ORDER BY SUM(t.amount)DESC) AS quartile 
 FROM transactions t JOIN customers c ON t.customer_id=c.customer_id GROUP BY c.customer_id,c.name ORDER BY total_spent DESC;


-- ScreenShot
![quartile](<screenshots/Customer Quartiles.PNG>)


--  Query 5: month average

 WITH monthly AS(SELECT TO_CHAR(DATE_TRUNC('month',sale_date),'YYYY-MM') as month,SUM(amount) AS total_sales 
 FROM transactions GROUP BY DATE_TRUNC('month',sale_date)) 
 SELECT month,total_sales,ROUND(AVG(total_sales) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS moving_avg_month from monthly ORDER BY month;

-- ScreenShot
![month average](<screenshots/month average.PNG>)



## Analysis

### Descriptive
- **Top Products (Query 1):** Amstel leads in Kigali and Muhanga, while Beer dominates in Huye.  
- **Running Monthly Totals (Query 2):** Sales dropped in February (22,000) but surged in March (68,500), with a running total reaching 142,500.  
- **Month-over-Month Growth (Query 3):** Negative growth in February (~-57.7%), followed by strong recovery in March (~211.4%).  
- **Customer Quartiles (Query 4):** Top spenders (Alice, Bryan, Diane) fall in Quartile 1, contributing most of the revenue.  
- **3-Month Moving Average (Query 5):** showing overall upward trend in sales.

### Diagnostic
- High sales of Amstel in Kigali and Muhanga indicate strong regional preference.  
- Dip in February may be due to fewer transactions or lower product demand that month.  
- Quartile analysis shows that a small group of customers contributes the majority of revenue.

### Prescriptive
- Focus marketing efforts on top-selling products per region to maximize revenue.  
- Engage top-quartile customers with loyalty programs or special offers.  
- Monitor lower-performing months and regions to identify opportunities for growth.

### REFERENCE
PostgreSQL Documentation – Window Functions: https://www.postgresql.org/docs/current/functions-window.html
Sqltutorial - https://www.sqltutorial.org/sql-window-functions/

## Integrity Statement
All work in this assignment, including SQL queries, analyses, and explanations, was completed by me. All results and interpretations are my own.
