-- Window Functions: OVER() CLAUSE
SELECT * FROM expenses;

-- -- show % of total expense
SELECT *, amount*100/SUM(amount) AS pct FROM expenses ORDER BY category; -- Shows wrt to total amount.

-- show % of total expense per category
SELECT * , amount*100/SUM(amount) 
OVER(PARTITION BY category) AS pct 
FROM expenses 
ORDER BY category, pct DESC;

-- Show expenses per category till date
SELECT * , SUM(amount) 
OVER(PARTITION BY category ORDER BY date) AS expenses_till_date 
FROM expenses;

-- -- find out customer wise net sales percentage contribution in 2021
with cte1 as (
		select 
                    customer, 
                    round(sum(net_sales)/1000000,2) as net_sales_mln
        	from net_sales s
        	join dim_customer c
                    on s.customer_code=c.customer_code
        	where s.fiscal_year=2021
        	group by customer)
	select 
            *,
            net_sales_mln*100/sum(net_sales_mln) over() as pct_net_sales
	from cte1
	order by net_sales_mln desc;

-- Find customer wise net sales distibution per region for FY 2021
with cte1 as (
		select 
        	    c.customer,
                    c.region,
                    round(sum(net_sales)/1000000,2) as net_sales_mln
                from gdb0041.net_sales n
                join dim_customer c
                    on n.customer_code=c.customer_code
		where fiscal_year=2021
		group by c.customer, c.region)
	select
             *,
             net_sales_mln*100/sum(net_sales_mln) over (partition by region) as pct_share_region
	from cte1
	order by region, pct_share_region desc;

-- RANK(), ROW_NUMBER(), DENSE_RANK()
-- Top 2 products from each category
WITH CTE AS(
SELECT *, 
	   ROW_NUMBER() OVER(PARTITION BY category ORDER BY amount DESC) AS rn FROM expenses
       ORDER BY category)
SELECT * FROM CTE WHERE rn<=2;

WITH CTE AS(
SELECT *, 
	   ROW_NUMBER() OVER(PARTITION BY category ORDER BY amount DESC) AS rn,
       RANK() OVER(PARTITION BY category ORDER BY amount DESC) AS rnk,
       DENSE_RANK() OVER(PARTITION BY category ORDER BY amount DESC) AS drnk FROM expenses
       ORDER BY category)
SELECT * FROM CTE WHERE rn<=2;

-- Find out top 3 products from each division by total quantity sold in a given year
with cte1 as 
		(select
                     p.division,
                     p.product,
                     sum(sold_quantity) as total_qty
                from fact_sales_monthly s
                join dim_product p
                      on p.product_code=s.product_code
                where fiscal_year=2021
                group by p.product),
           cte2 as 
	        (select 
                     *,
                     dense_rank() over (partition by division order by total_qty desc) as drnk
                from cte1)
select * from cte2 where drnk<=3;



       
