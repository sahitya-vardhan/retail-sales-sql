--project 2: reatil sales analysis--
--Database: reatil_practice.db(table:sales)--
--author: Sahitya vardhan--

--Q:category performance vs target
SELECT sum("Total Amount") FROM sales
WHERE "Product Category" = 'Beauty';

--Q:show total sales per category.
SELECT categories.category_name, sum(sales."Total Amount") AS actual_sales FROM sales
INNER JOIN categories ON sales."Product Category" = categories.category_name
GROUP BY categories.category_name
HAVING sum(sales."Total Amount") > 4000;

--Q:SUB QUERIES 
SELECT * FROM sales
WHERE "Total Amount" > ( SELECT avg("Total Amount") FROM sales);

--Q: group by + having
select "Product Category", count(*) FROM sales
group by "Product Category";

--Q: using group by + having retrive the female transactions above the 250
select "Product Category", Gender, sum("Total Amount") AS total_sales FROM sales
Where Gender = 'Female'
group by "Product Category"
having sum("Total Amount") > 250;

--Q:average quantity per product category
select "Product Category", avg("Quantity") FROM sales
group by "Product Category";


--Q:USE ROW_NUMBER WITH PARTITON BY TO NUMBER TRANSACTIONS WITHIN THE EACH GENDER GROUP, ORDER BY QUANTITY DESCENDING.
select row_number()over(PARTITION BY "Gender" ORDER BY "Quantity" DESC) AS EXAMPLE_SET, "Transaction ID", "Quantity", "Gender" FROM sales;

--Q:USING QUERY 3 ABOVE AS A BASE, WRITE A QUERY THAT SHOWS ONLY THE TOP RANKED (RANK =1) TRANSACTION PER CATEGORY
select "product_category","Transaction ID" , "Total Amount" FROM (SELECT "product_category","Transaction ID" , "Total Amount", row_number() over(PARTITION BY "product_category" order by "Total Amount" DESC) RowNum FROM sales)
WHERE
RowNum = 1;

--Q: what is the highest value transaction for each product category
SELECT "date", "Total Amount", "product_category", sum("Total Amount") OVER (PARTITION BY "product_category" ORDER BY "date") AS running_total FROM sales;

--Q:show each sale with its previous days amount and how much it changed?
SELECT "date", "Total Amount", "product_category", lag("Total Amount") OVER (ORDER BY "date") AS PREVIOUS_AMT,
"Total Amount" - lag("Total Amount") OVER (ORDER BY "date") AS change FROM sales;

--Q: what are the top3 highest value transactions for each product caatgeory?
select *FROM (select "product_category", "date", "Total Amount", row_number()over( PARTITION BY "product_category" ORDER BY"Total Amount" DESC) AS rn FROM sales)
WHERE rn <=3;

--Q:WHAT ARE THE TOP 2 HIGHEST VALUE TRANSACTIONS FOR EACH PRODUCT CATEGORY
SELECT "date", "product_category", "Total Amount" FROM (SELECT "date", "product_category", "Total Amount", row_number()OVER( PARTITION BY "product_category" ORDER BY "Total Amount" DESC) AS top2_trans FROM sales)
WHERE top2_trans <= 2
;

--Q:WHAT PERCENTAGE DOES EACH TRANSACTION CONTRIBUTE TO ITS CATEGORY TOTAL SALES
SELECT "date", "product_category", "Total Amount",round("Total Amount" * 100 / sum("Total Amount")OVER( PARTITION BY "product_category" ORDER BY "Total Amount" DESC),2) AS pct_by_category FROM sales

--Q: HOW MANY TRANSACTIONS ARE HIGH, MEDIUM OR LOW VALUE?
SELECT count(*) AS CNT, "date", "product_category", "Total Amount", CASE WHEN "Total Amount" >= 1000 THEN "High" WHEN "Total Amount" >= 300 THEN "medium" ELSE 'LOW' END AS SIZE_LABEL FROM sales
GROUP BY "SIZE_LABEL"

--Q:what is the total value of beauty transactions of 500 or more?
SELECT sum("Total Amount") FROM sales
WHERE "product_category" = 'Beauty' AND "Total Amount" >= 500;

--Q:Revenue by month. In SQLite, strftime('%m', date) pulls the month from the date. Group by it.
SELECT strftime('%m', date) as month, sum("total_amount") as revenue from sales
GROUP BY strftime('%m', date)
ORDER BY month

--Q:The count of High, Medium and Low labels by category. Hint: put your CASE WHEN inside a derived table, then GROUP BY product_category, size_label.
SELECT "date", "product_category" "total_amount",
CASE when "total_amount" >= 1000 THEN 'HIGH'
WHEN "total_amount" >300 THEN 'MEDIUM'
ELSE'low'
END AS SIZE_LABEL FROM sales
GROUP BY "product_category", SIZE_LABEL
ORDER BY "DATE" ASC;

--Q:combining in The count of High, Medium and Low labels by category. Hint: put your CASE WHEN inside a derived table, then GROUP BY product_category, size_label.

--Q:my question “how much revenue does each size band bring per category per month? --Q:

SELECT "product_category", "total_amount", strftime('%m', date) AS month, SUM("total_amount") AS revenue, count(\*) as transactions,
CASE when "total_amount" >= 1000 THEN 'HIGH'
WHEN "total_amount" >300 THEN 'MEDIUM'
ELSE'low'
END AS SIZE_LABEL FROM sales
GROUP BY "product_category", SIZE_LABEL, strftime('%m', date)
ORDER BY month;
