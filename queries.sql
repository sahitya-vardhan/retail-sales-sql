--project 2: retail sales analysis--
--Database: retail_practice.db(table:sales)--
--author: Sahitya vardhan--

--Q: category performance vs target
SELECT SUM("Total Amount") AS total_beauty_sales
FROM sales
WHERE "Product Category" = 'Beauty';

--Q: show total sales per category.
SELECT categories.category_name, SUM(sales."Total Amount") AS actual_sales
FROM sales
INNER JOIN categories ON sales."Product Category" = categories.category_name
GROUP BY categories.category_name
HAVING SUM(sales."Total Amount") > 4000;

--Q: SUB QUERIES
SELECT *
FROM sales
WHERE "Total Amount" > (SELECT AVG("Total Amount") FROM sales);

--Q: group by + having
SELECT "Product Category", COUNT(*) AS transaction_count
FROM sales
GROUP BY "Product Category";

--Q: using group by + having retrieve the female transactions above 250
SELECT "Product Category", Gender, SUM("Total Amount") AS total_sales
FROM sales
WHERE Gender = 'Female'
GROUP BY "Product Category", Gender
HAVING SUM("Total Amount") > 250;

--Q: average quantity per product category
SELECT "Product Category", AVG("Quantity") AS avg_quantity
FROM sales
GROUP BY "Product Category";

--Q: use ROW_NUMBER with PARTITION BY to number transactions within each gender group, ordered by quantity descending.
SELECT ROW_NUMBER() OVER (PARTITION BY "Gender" ORDER BY "Quantity" DESC) AS example_set,
       "Transaction ID",
       "Quantity",
       "Gender"
FROM sales;

--Q: using the query above as a base, show only the top-ranked (rank = 1) transaction per category
SELECT "product_category", "Transaction ID", "Total Amount"
FROM (
    SELECT "product_category",
           "Transaction ID",
           "Total Amount",
           ROW_NUMBER() OVER (PARTITION BY "product_category" ORDER BY "Total Amount" DESC) AS RowNum
    FROM sales
) AS ranked
WHERE RowNum = 1;

--Q: what is the highest value transaction for each product category
SELECT "date", "Total Amount", "product_category",
       SUM("Total Amount") OVER (PARTITION BY "product_category" ORDER BY "date") AS running_total
FROM sales;

--Q: show each sale with its previous day amount and how much it changed
SELECT "date",
       "Total Amount",
       "product_category",
       LAG("Total Amount") OVER (ORDER BY "date") AS previous_amt,
       "Total Amount" - LAG("Total Amount") OVER (ORDER BY "date") AS change
FROM sales;

--Q: what are the top 3 highest value transactions for each product category?
SELECT *
FROM (
    SELECT "product_category",
           "date",
           "Total Amount",
           ROW_NUMBER() OVER (PARTITION BY "product_category" ORDER BY "Total Amount" DESC) AS rn
    FROM sales
) AS ranked_sales
WHERE rn <= 3;

--Q: what are the top 2 highest value transactions for each product category?
SELECT "date", "product_category", "Total Amount"
FROM (
    SELECT "date",
           "product_category",
           "Total Amount",
           ROW_NUMBER() OVER (PARTITION BY "product_category" ORDER BY "Total Amount" DESC) AS top2_trans
    FROM sales
) AS ranked_sales
WHERE top2_trans <= 2;

--Q: what percentage does each transaction contribute to its category total sales?
SELECT "date",
       "product_category",
       "Total Amount",
       ROUND("Total Amount" * 100.0 / SUM("Total Amount") OVER (PARTITION BY "product_category"), 2) AS pct_by_category
FROM sales;

--Q: how many transactions are high, medium or low value?
SELECT COUNT(*) AS cnt,
       CASE
           WHEN "Total Amount" >= 1000 THEN 'High'
           WHEN "Total Amount" >= 300 THEN 'Medium'
           ELSE 'Low'
       END AS size_label
FROM sales
GROUP BY CASE
             WHEN "Total Amount" >= 1000 THEN 'High'
             WHEN "Total Amount" >= 300 THEN 'Medium'
             ELSE 'Low'
         END;

--Q: what is the total value of beauty transactions of 500 or more?
SELECT SUM("Total Amount") AS total_beauty_revenue
FROM sales
WHERE "product_category" = 'Beauty' AND "Total Amount" >= 500;

--Q: revenue by month. In SQLite, strftime('%m', date) pulls the month from the date. Group by it.
SELECT strftime('%m', "date") AS month,
       SUM("total_amount") AS revenue
FROM sales
GROUP BY strftime('%m', "date")
ORDER BY month;

--Q: the count of High, Medium and Low labels by category. Hint: put your CASE WHEN inside a derived table, then GROUP BY product_category, size_label.
SELECT "product_category",
       size_label,
       COUNT(*) AS label_count
FROM (
    SELECT "product_category",
           CASE
               WHEN "total_amount" >= 1000 THEN 'HIGH'
               WHEN "total_amount" > 300 THEN 'MEDIUM'
               ELSE 'LOW'
           END AS size_label
    FROM sales
) AS labeled_sales
GROUP BY "product_category", size_label
ORDER BY "product_category", size_label;

--Q: my question: how much revenue does each size band bring per category per month?
SELECT "product_category",
       strftime('%m', "date") AS month,
       CASE
           WHEN "total_amount" >= 1000 THEN 'HIGH'
           WHEN "total_amount" > 300 THEN 'MEDIUM'
           ELSE 'LOW'
       END AS size_label,
       SUM("total_amount") AS revenue,
       COUNT(*) AS transactions
FROM sales
GROUP BY "product_category",
         CASE
             WHEN "total_amount" >= 1000 THEN 'HIGH'
             WHEN "total_amount" > 300 THEN 'MEDIUM'
             ELSE 'LOW'
         END,
         strftime('%m', "date")
ORDER BY month;

--Q: who are the top 3 customers by total spend, and how many transactions did each make?
SELECT "customer_id",
       COUNT(*) AS transactions,
       SUM("total_amount") AS total_spend
FROM sales
GROUP BY "customer_id"
ORDER BY total_spend DESC
LIMIT 3;