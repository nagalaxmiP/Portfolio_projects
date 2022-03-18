Data Analysis Using SQL




SELECT * FROM customers;
SELECT * FROM transactions;
SELECT * FROM markets;
SELECT * FROM products;
SELECT * FROM date;
SELECT count(*) FROM customers;
SELECT * FROM transactions where market_code='Mark001';
SELECT distinct product_code FROM transactions where market_code='Mark001';
SELECT * from transactions where currency="USD"

#checking for duplicates in the currency column
select* from sales.transactions
where currency='usd' or currency='usd\r'

# revenue By year
SELECT sum(trans.sales_amount) FROM sales.transactions as trans inner join sales.date dat on 
trans.order_date=dat.date
where dat.year=2020
order by trans.market_code;

#sales Quantity by year
SELECT sum(trans.sales_qty) FROM sales.transactions as trans inner join sales.date dat on 
trans.order_date=dat.date
where dat.year=2020
order by trans.market_code;

# transactions in 2020 joined by date table
SELECT transactions.*, date.* FROM transactions
 INNER JOIN date ON transactions.order_date=date.date where date.year=2020;

#sum of sales each year
select x.year,sum(x.sales_amount) as sum_sales_amnt from (SELECT * FROM sales.transactions as trans inner join sales.date dat on 
trans.order_date=dat.date)  as x
group by x.year;

# sum of salesquantity by year
select x.year,sum(x.sales_qty) as sum_sales_amnt from (SELECT * FROM sales.transactions as trans inner join sales.date dat on 
trans.order_date=dat.date)  as x
group by x.year;
#total revenue in all years in chennai
select x.year,x.market_code,sum(x.sales_amount) as sum_sales_amnt from 
(SELECT * FROM sales.transactions as trans inner join sales.date dat on 
trans.order_date=dat.date)  as x
where x.market_code='Mark001'
group by x.year;
# total revenue in the year 2020 january
SELECT SUM(transactions.sales_amount) FROM transactions
 INNER JOIN date ON transactions.order_date=date.date 
 where date.year=2020 and  date.month_name="January" 
 and (transactions.currency="INR\r" or transactions.currency="USD\r");


