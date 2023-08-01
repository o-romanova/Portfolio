Olga Romanova
#Portfolio. Business Intelligence Analyst

This entire project is based on the same [Superstore dataset](Sample-Superstore.xls).

## SQL
To start with, I decided trying working with this dataset without any changes. Below are some examples of queries that repeat questions that I asked in data visualization parts.

I used PostgreSQL and DBeaver.

### 1.1 KPIs
```sql
/*Profit per month compared to the same month of the previous year (Year over year comparison)*/

SELECT
	date_trunc('month', order_date) AS order_month,
	ROUND(SUM(profit), 1) AS profit_by_month,
	ROUND(LAG(SUM(profit), 12) OVER w, 1) AS profit_prev_period,
	ROUND((SUM(profit)/LAG(SUM(profit), 12) OVER w - 1) * 100, 1) AS percent_difference
FROM
	orders o
GROUP BY
	order_month
WINDOW w AS (ORDER BY date_trunc('month', order_date))
ORDER BY 
	order_month;
```
![profit monthly yoy](SQL/profit_montly_yoy.png)

Other KPIs are obtained the same way.

```sql
--Yearly KPI change, change is shown in percent

SELECT
	date_trunc('year', order_date) as year,
	ROUND(SUM(profit), 1) AS profit,
	ROUND((SUM(profit) / LAG(SUM(profit)) OVER w - 1) * 100, 1) AS profit_change,
	ROUND(SUM(sales), 1) AS sales,
	ROUND((SUM(sales) / LAG (SUM(sales)) OVER w - 1) * 100, 1) AS sales_change,
	COUNT(distinct order_id) AS orders,
	ROUND((count(distinct order_id)::numeric / LAG(count(distinct order_id)::numeric) OVER w - 1) * 100, 1) AS orders_change,
	ROUND(SUM(profit)/SUM(sales) *100, 1) AS profit_margin,
	ROUND(((SUM(profit)/SUM(sales)) / LAG(SUM(profit)/SUM(sales)) OVER w - 1) * 100, 1) AS profit_margin_change
FROM
        public.orders
GROUP BY
    year
WINDOW w AS (ORDER BY date_trunc('year', order_date))
ORDER BY
    year;
```

![kpi yearly](SQL/kpi-yearly.png)

### 1.2 Lost profit by state
```sql
/* Lost profit. Returned orders by state */

select
	state,
	SUM(sales) as returned_sales_sum,
	COUNT(returned) as returned_order_count
from
	public.orders as o
join
	(select
		distinct order_id,
		returned
	from
		public."returns") as r
on o.order_id = r.order_id
group by
	state,
	r.returned
order by
	returned_sales_sum desc;
```

![lost profit by state](SQL/lost_profit_by_state.png)


### 1.3 Top 10 products by profit
```sql
/* Top 10 product by profit */
select
	product_name,
	ROUND(SUM(profit), 2) as profit_sum
from
	public.orders
group by
	product_name,
	orders.order_date
--filter by year if necessary
having 
	date_trunc('year', order_date) = '2018-01-01'
order by
	SUM(profit) desc
limit 
	10;			
```

![top 10 products by profit](SQL/top_10_products_profit.png)

You can see the [SQL script](Portfolio/SQL/sql-queries_superstore-db.sql) for details.

## DATA MODEL

For creating a data model I used [SqlDBM](https://sqldbm.com).
![Physical data model](data_model_superstoredb.png)

See the script [here](Portfolio/SQL/from_stg_to_dw_superstore.sql). I connected AWS RDS to my PostgreSQL instance.

## TABLEAU
I decided to answer the same questions as in SQL section with Tableau. 
![Tableau profit summary 1](Portfolio/dataviz/Tableau_superstore_summary_1.png)
