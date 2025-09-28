-- Queries to create sample tables for a sales database 
--which holds information about customers,products and transactions


CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    product_id INT REFERENCES products(product_id),
    sale_date DATE,
    amount DECIMAL(10,2)
);


-- insert sample data into customers table 

INSERT INTO customers (customer_id, name, region) VALUES
(1, 'Alice', 'Kigali'),
(2, 'Bryan', 'Kigali'),
(3, 'Charles', 'Huye'),
(4, 'Diane', 'Muhanga'),
(5, 'Jacob', 'Huye');

-- insert sample data into products table

INSERT INTO products (product_id, name, category) VALUES
(1, 'Amstel', 'Beer'),
(2, 'Mützig', 'Beer'),
(3, 'Coca-Cola', 'Soft Drink'),
(4, 'Sprite', 'Soft Drink'),
(5, 'Nile', 'Water');

-- insert sample data into transactions table

INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES
(1, 1, 1, '2025-01-05', 15000.00),
(2, 1, 1, '2025-01-20', 12000.00),
(3, 2, 1, '2025-01-10', 18000.00),
(4, 2, 3, '2025-02-15', 5000.00),
(5, 3, 4, '2025-01-25', 7000.00),
(6, 3, 5, '2025-02-05', 3000.00),
(7, 4, 2, '2025-02-10', 14000.00),
(8, 4, 1, '2025-03-01', 16000.00),
(9, 5, 3, '2025-03-05', 4000.00),
(10, 5, 5, '2025-03-10', 2000.00),
(11, 1, 3, '2025-03-15', 6000.00),
(12, 2, 4, '2025-03-20', 8000.00),
(13, 3, 2, '2025-03-22', 13000.00),
(14, 4, 5, '2025-03-25', 2500.00),
(15, 5, 1, '2025-03-28', 17000.00);

-- Query 1: Ranking top customers by total sales

Select c.region,p.name AS product_name,SUM(T.amount) AS total_sales,RANK() OVER (PARTITION BY c.region 
ORDER BY SUM(t.amount)DESC) AS product_rank FROM transactions t 
JOIN customers c ON t.customer_id=c.customer_id
JOIN products P ON t.product_id=p.product_id GROUP BY c.region,p.name ORDER BY c.region, total_sales DESC;

-- Query 2: Running Monthly Totals

select TO_CHAR(DATE_TRUNC('month',t.sale_date),'YYYY-MM') AS month,SUM(t.amount) AS monthly_sales,
SUM(SUM(t.amount)) OVER (ORDER BY DATE_TRUNC('month',t.sale_date)) AS running _total 
FROM transactions t GROUP BY DATE_TRUNC('month',t.sale_date) ORDER BY month;

-- Query 3: Month-over-Month Growth

 WITH monthly AS(SELECT TO_CHAR(DATE_TRUNC('month',sale_date),'YYYY-MM') AS month,SUM(amount) AS Total_sales
 FROM transactions GROUP BY DATE_TRUNC('month',sale_date)) 
 SELECT month,Total_sales,LAG(Total_sales) OVER (ORDER BY month) AS previous_month,(Total_sales - LAG(total_sales) OVER (ORDER BY month)) AS growth 
 FROM monthly ORDER BY month;

 --Query 4 : Customer Quartiles 

 SELECT c.name AS customer_name,SUM(t.amount) AS total_spent,NTILE(4) OVER (ORDER BY SUM(t.amount)DESC) AS quartile 
 FROM transactions t JOIN customers c ON t.customer_id=c.customer_id GROUP BY c.customer_id,c.name ORDER BY total_spent DESC;

 --Query 5: month average

 WITH monthly AS(SELECT TO_CHAR(DATE_TRUNC('month',sale_date),'YYYY-MM') as month,SUM(amount) AS total_sales 
 FROM transactions GROUP BY DATE_TRUNC('month',sale_date)) 
 SELECT month,total_sales,ROUND(AVG(total_sales) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS moving_avg_month from monthly ORDER BY month;