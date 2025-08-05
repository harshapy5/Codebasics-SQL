-- Task 1
-- Croma India product wise Sales report for Fiscal Year 2021
-- Report Should have following fields.
	-- Month
    -- Product Name
    -- Variant
    -- Sold Quantity
    -- Gross Price Per Item
    -- Gross Price total
    
-- Break the task into pieces.
-- Retrieve the customer code for Croma from "dim_customer" table to get the customer_code
SELECT * FROM dim_customer WHERE customer LIKE '%Croma%';

-- Get all the procuct_code from "fact_sales_monthly" for the customer_code "90002002"
SELECT * FROM fact_sales_monthly WHERE customer_code = 90002002;

-- Now we need to get the report for fiscal_year 2021. But we don't have a fiscal_year. Define the fiscal_year first and read the data.
-- Method 1
SELECT * FROM fact_sales_monthly
	WHERE customer_code = 90002002 AND 
	YEAR(DATE_ADD(date, INTERVAL 4 MONTH)) = 2021
ORDER BY date DESC;

-- The above method works but we need to invoke the pre-defined function everytime. We will have our own function to get the fiscal_year.
-- Method 2. Create a user defined function to get the fiscal_year.

CREATE FUNCTION `get_fiscal_year`(calendar_date DATE) RETURNS int
DETERMINISTIC
BEGIN
	DECLARE fiscal_year INT;
    SET fiscal_year = YEAR(DATE_ADD(calendar_date,INTERVAL 4 MONTH));
    RETURN fiscal_year;
END

-- Now retrieve the products for Croma for fiscal_year 2021.

SELECT * FROM fact_sales_monthly
WHERE customer_code = 90002002
AND get_fiscal_year(date) = 2021
ORDER BY date DESC;

-- We need to get Product Name, Variant, gross price from dim_produc table and fact_gross_price tables

SELECT s.date, s.product_code, p.product,p.variant,s.sold_quantity,
	   ROUND(g.gross_price,2) AS gross_price,ROUND(s.sold_quantity*g.gross_price,2) AS gross_price_total
FROM fact_sales_monthly s
JOIN dim_product p
ON p.product_code = s.product_code
JOIN fact_gross_price g
ON g.fiscal_year = get_fiscal_year(s.date) AND g.product_code = p.product_code
WHERE customer_code = 90002002 AND 
	  get_fiscal_year(s.date) = 2021
ORDER BY date DESC; 

-- Task 2
-- Gross Monthly total Sales Report for Croma
-- Report should have following fields
	-- Month
    -- Total gross sales to croma in this month

SELECT
	s.date,
    ROUND(SUM(s.sold_quantity*g.gross_price),2) AS gross_price_total
FROM fact_sales_monthly s
JOIN fact_gross_price g
ON g.product_code = s.product_code AND g.fiscal_year = get_fiscal_year(s.date)
WHERE customer_code = 90002002
GROUP BY s.date
ORDER BY s.date DESC;

-- Generate a yearly report for Croma India where there are two columns
	-- Fiscal Year
	-- Total Gross Sales amount In that year from Croma
 SELECT
	get_fiscaL_year(s.date) AS fiscal_year,
    ROUND(SUM(s.sold_quantity*g.gross_price),2) AS gross_price_total
FROM fact_sales_monthly s
JOIN fact_gross_price g
ON g.product_code = s.product_code AND g.fiscal_year = get_fiscal_year(s.date)
WHERE customer_code = 90002002
GROUP BY fiscal_year
ORDER BY fiscal_year;   

### Module: Stored Procedures: Monthly Gross Sales Report

-- Generate monthly gross sales report for any customer using stored procedure
CREATE PROCEDURE `get_monthly_gross_sales_for_customer`(
	in_customer_codes TEXT)
BEGIN
	SELECT s.date, SUM(ROUND(s.sold_quantity*g.gross_price,2)) as monthly_sales
		FROM fact_sales_monthly s
		JOIN fact_gross_price g
		ON g.fiscal_year=get_fiscal_year(s.date)
		AND g.product_code=s.product_code
	WHERE 
	FIND_IN_SET(s.customer_code, in_customer_codes) > 0
	GROUP BY s.date
	ORDER BY s.date DESC;
END

### Module: Stored Procedure: Market Badge

--  Write a stored proc that can retrieve market badge. i.e. if total sold quantity > 5 million that market is considered "Gold" else "Silver"
CREATE PROCEDURE `get_market_badge`(
	IN in_market VARCHAR(45),
	IN in_fiscal_year YEAR,
	OUT out_level VARCHAR(45)
	)
BEGIN
	DECLARE qty INT DEFAULT 0;
    # Default market is India
	IF in_market = "" THEN
		SET in_market="India";
	END IF;
# Retrieve total sold quantity for a given market in a given year
SELECT 
	SUM(s.sold_quantity) INTO qty
	FROM fact_sales_monthly s
	JOIN dim_customer c
	ON s.customer_code=c.customer_code
	WHERE 
	get_fiscal_year(s.date)=in_fiscal_year AND
	c.market=in_market;
# Determine Gold vs Silver status
	IF qty > 5000000 THEN
	SET out_level = 'Gold';
	ELSE
	SET out_level = 'Silver';
	END IF;
END

