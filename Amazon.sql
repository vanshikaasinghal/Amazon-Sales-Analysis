CREATE DATABASE AMAZON;
USE AMAZON;


SELECT * FROM AMAZON_SALE;
SELECT DISTINCT Product_Category FROM AMAZON_SALE;



------- WHAT IS THE AVERGAE PROFIT MARGIN PER PRODUCT CATEGORY --------------

CREATE VIEW Average_Profit_Category AS
SELECT Product_Category,
    ROUND(AVG (Original_Price - Discounted_Price), 2) AS Avg_Profit_Margin
FROM AMAZON_SALE
GROUP BY Product_Category;

---- FINAL----

SELECT * FROM Average_Profit_Category;


------- WHAT IS THE TOP SELLING PRODUCT IN EACH CATEGORY LAST MONTH ---------


CREATE VIEW Top_Selling_Product AS
SELECT TOP 1 WITH TIES
Product_Title, Product_Category, Purchased_Last_Month
FROM AMAZON_SALE
ORDER BY ROW_NUMBER() OVER (PARTITION BY Product_Category
ORDER BY Purchased_Last_Month DESC);


---- FINAL----

SELECT * FROM Top_Selling_Product;


------ TOP 10 HIGHEST DISCOUNTED PRODUCTS -------


CREATE VIEW Highest_Discounted_Products AS
SELECT TOP 10 Product_Title, Product_Category, 
ROUND(MAX(Original_Price - Discounted_Price) , 2) AS Discount_Amount
FROM AMAZON_SALE
GROUP BY Product_Category, Product_Title
ORDER BY Discount_Amount DESC;



---- FINAL----

SELECT * FROM Highest_Discounted_Products;


------ PRODUCT WITH A PERFECT RATING OF 5 --------


CREATE VIEW Best_Rated_Product AS
SELECT DISTINCT Product_Title, Product_Category, Product_Rating, Total_Reviews
FROM AMAZON_SALE
WHERE Product_Rating = 5
ORDER BY Total_Reviews DESC
OFFSET 0 ROWS;



---- FINAL----

SELECT * FROM Best_Rated_Product;



------ TOP 3 PRODUCTS WITH HIGHEST REVIEWS --------



CREATE VIEW Highest_Reviewed_Products AS
WITH Ranked AS (
SELECT Product_Title, Product_Category, 
FLOOR(Total_Reviews) AS Total_Reviews,
ROW_NUMBER() OVER (ORDER BY Total_Reviews DESC) AS rn
FROM AMAZON_SALE
)
SELECT Product_Title, Product_Category, Total_Reviews
FROM Ranked
WHERE rn <= 3;



---- FINAL----

SELECT * FROM Highest_Reviewed_Products;


------ CORRELATION BETWEEN SALES AND PRICE -----


CREATE VIEW Sales_and_Price AS
SELECT 
   DISTINCT Product_Title, Product_Category, FLOOR(Discounted_Price) AS Price,
    Purchased_Last_Month AS Sales
FROM AMAZON_SALE
ORDER BY Sales DESC, Price ASC
OFFSET 0 ROWS;


---- FINAL----

SELECT * FROM Sales_and_Price;



------ WHICH PRODUCTS ARE BEST SELLERS BUT HAVE LOW RECENT PURCHASES ----


CREATE VIEW Best_Seller_Products AS
SELECT Product_Title, Product_Category,  Purchased_Last_Month,  Is_Best_Seller
FROM AMAZON_SALE
WHERE Is_Best_Seller = 'Best Seller'
ORDER BY  Purchased_Last_Month ASC
OFFSET 0 ROWS;




---- FINAL----

SELECT * FROM Best_Seller_Products;



------ CATEGORY WISE TOTAL REVENUE AND UNITS -----


CREATE VIEW Total_Revenue_For_Category AS
SELECT Product_Category,
SUM (Purchased_Last_Month) AS Total_Units,
FLOOR(SUM (Purchased_Last_Month * Discounted_Price)) AS Total_Revenue
FROM AMAZON_SALE
GROUP BY Product_Category
ORDER BY Total_Revenue DESC
OFFSET 0 ROWS;



---- FINAL----

SELECT * FROM Total_Revenue_For_Category;


----- WHICH PRODUCTS HAVE RATING BELOW 3.5 BUT STILL SELL WELL ---------


CREATE VIEW Low_Rating_Products AS
SELECT Product_Title, Product_Category, FLOOR(Product_Rating) AS Rating,
    Purchased_Last_Month, Total_Reviews
FROM AMAZON_SALE
WHERE Product_Rating < 3.5
ORDER BY Purchased_Last_Month DESC
OFFSET 0 ROWS;



---- FINAL----

SELECT * FROM Low_Rating_Products;



------ WHAT IS THE AVERAGE DISCOUNT PER CATEGORY AND HOW DOES IT AFFECT SALES -----


CREATE VIEW Average_Discounts AS
SELECT Product_Category,
ROUND(AVG(Original_Price - Discounted_Price), 2) AS Avg_Discount,
ROUND(AVG((Original_Price - Discounted_Price) / NULLIF (Original_Price, 0)*100), 2) AS Avg_Discount_Percentage,
SUM(Purchased_Last_Month) AS Total_Units
FROM AMAZON_SALE
GROUP BY Product_Category
ORDER BY Avg_Discount_Percentage DESC
OFFSET 0 ROWS;


---- FINAL----

SELECT * FROM Average_Discounts;



------ WHAT IS THE AVERAGE SELLING PRICE AND TOTAL REVENUE PER CATEGORY --------


CREATE VIEW Price_And_Revenue AS
SELECT Product_Category, 
FLOOR(AVG(Discounted_Price)) AS Avg_Selling_Price,
FLOOR (SUM (Purchased_Last_Month * Discounted_Price)) AS Total_Revenue
FROM AMAZON_SALE
GROUP BY Product_Category
ORDER BY Total_Revenue
OFFSET 0 ROWS;



---- FINAL----

SELECT * FROM Price_And_Revenue;


------ CATEGORIES WITH DECLINING SALES DESPITE OFFERING HIGHER DISCOUNTS -------


CREATE VIEW Declining_Sales AS
SELECT Product_Category,
ROUND( AVG((Original_Price - Discounted_Price)/ NULLIF (Original_Price, 0) *100), 2) AS Avg_Discount_Percentage,
SUM (Purchased_Last_Month) AS Total_Units_Sold
FROM AMAZON_SALE
GROUP BY Product_Category
HAVING ROUND( AVG((Original_Price - Discounted_Price)/ NULLIF (Original_Price, 0) *100), 2) >10
ORDER BY Total_Units_Sold ASC
OFFSET 0 ROWS;



---- FINAL----

SELECT * FROM Declining_Sales;


------ TOP 5 SELLING PRODUCTS IN EACH CATEGORY -----


CREATE VIEW Top_5_Products AS
WITH ProductSales AS (
SELECT Product_Category, Product_Title,
SUM(Purchased_Last_Month) AS Total_Units_Sold
FROM AMAZON_SALE
GROUP BY Product_Category, Product_Title
),
RankedSales AS (
SELECT
Product_Category, Product_Title, Total_Units_Sold,
RANK() OVER (
PARTITION BY Product_Category
ORDER BY Total_Units_Sold DESC
) AS RankInCategory
FROM ProductSales
)
SELECT Product_Category, Product_Title, Total_Units_Sold, RankInCategory
FROM RankedSales
WHERE RankInCategory <= 5
ORDER BY Product_Category, RankInCategory
OFFSET 0 ROWS;




---- FINAL----

SELECT * FROM Top_5_Products;
