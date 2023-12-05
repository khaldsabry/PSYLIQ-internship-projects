
--changing the name of month columns cause it's a func so we can't use as a column name

EXEC sp_RENAME 'dbo.cleaned_pharma_data.month', 'month_', 'COLUMN';

--retriving all columns and records in the dataset
select * 
from cleaned_pharma_data

--number of unique countries are represented in the dataset
SELECT COUNT(DISTINCT country) AS distinct_country
FROM cleaned_pharma_data;

--names of all the customers on the 'Retail' channel

select customer_name 
from cleaned_pharma_data
where Sub_channel= 'Retail'

--total quantity sold for the ' Antibiotics' product class.
select sum(Quantity) as total_quantity_sold
from cleaned_pharma_data
where Product_Class= 'Antibiotics' 

--the distinct months in dataset
SELECT DISTINCT month_
FROM cleaned_pharma_data

--total sales for each year
select year_ as years, sum(sales) as total_sales
from cleaned_pharma_data
group by year_ 
order by year_ asc

--customer with the highest sales value
SELECT customer_name,sales
FROM cleaned_pharma_data
WHERE sales = (SELECT MAX(sales) FROM cleaned_pharma_data);

--names of sales reps managed by james good will
select distinct name_of_sales_rep
from cleaned_pharma_data
where manager = 'James Goodwill'

--top 5 cities with the highest sales
SELECT TOP 5 City, SUM(Sales) AS TotalSales
FROM cleaned_pharma_data
GROUP BY City
ORDER BY TotalSales DESC
--avg price of products in each sub-channel
select Sub_channel,Avg(price) as average_price
from cleaned_pharma_data
group by Sub_channel

--sales made by employees from rensburg in 2018

select  distinct name_of_sales_rep, sum(sales)as total_sales_by_emp
from cleaned_pharma_data
where city= 'Rendsburg' and year_ = 2018
group by  name_of_sales_rep
--another way
select  distinct name_of_sales_rep, year_
from cleaned_pharma_data
where city= 'Rendsburg' and year_ = 2018 (select sum(sales)as total_sales_by_emp from cleaned_pharma_data)

--total sales for product class and each month
select 
product_class,
month_,
year_,
sum (sales) as total_sales_for_product_class
from cleaned_pharma_data
group by
Product_Class,
month_,
year_
order by
year_,
month_,
Product_Class
--top 3 sales reps with the highest sales in 2019
SELECT top 3 Name_of_Sales_Rep,sum(sales) as total_sales,year_
FROM cleaned_pharma_data
WHERE  year_ = 2019
group by Name_of_Sales_Rep, year_
order by total_sales desc
--monthly sales for each sub channel & the avg monthly sales for each sub channel over the year
with monthly_salesCTE AS (
		select Sub_channel,month_,year_, sum (sales) as total_monthly_sales
		from cleaned_pharma_data
		group by Sub_channel,month_,year_
		)
 select sub_channel, avg(total_monthly_sales) as avg_of_total_monthly_sales
 from monthly_salesCTE 
 group by Sub_channel
 order by Sub_channel

  --summary report that includes the total sales, average price, and total quantity sold for 
  --each product class.
 SELECT
    Product_Class,
    SUM(Sales) AS TotalSales,
    AVG(Price) AS AveragePrice,
    SUM(Quantity) AS TotalQuantitySold
FROM 
    cleaned_pharma_data
GROUP BY 
    Product_Class

--Top 5 customers with the highest sales for each year
WITH top5Customers AS (
    SELECT
        Customer_name,
        year_ AS SaleYear,
        SUM(Sales) AS TotalSales,
        ROW_NUMBER() OVER (PARTITION BY year_ ORDER BY SUM(Sales) DESC) AS SalesRank
    FROM
        cleaned_pharma_data
    GROUP BY
        Customer_Name, year_
)

SELECT
    Customer_name,
    SaleYear ,
    TotalSales
FROM
    top5Customers
WHERE
    SalesRank <= 5
ORDER BY
    SaleYear, TotalSales DESC

--the year-over-year growth in sales for each country
WITH SalesByYear AS (
    SELECT
        Country,
        year_ AS SaleYear,
        SUM(Sales) AS TotalSales
    FROM
        cleaned_pharma_data
    GROUP BY
        Country, year_
)
SELECT
    Country,
    SaleYear AS Year,
    TotalSales,
    LAG(TotalSales) OVER (PARTITION BY Country ORDER BY SaleYear) AS PrevYearSales,
    ROUND(((TotalSales - LAG(TotalSales) OVER (PARTITION BY Country ORDER BY SaleYear)) / LAG(TotalSales) OVER (PARTITION BY Country ORDER BY SaleYear)) * 100, 2) AS YoYSalesGrowth
FROM
    SalesByYear
ORDER BY
    Country, SaleYear;

--lowest sales months for each year
WITH lowedtdslesMonths AS (
    SELECT
        year_ AS SaleYear,
        month_ AS SaleMonth,
        SUM(Sales) AS TotalSales,
        RANK() OVER (PARTITION BY year_ ORDER BY SUM(Sales) ASC) AS SalesRank
    FROM
        cleaned_pharma_data
    GROUP BY
        year_, month_
)

SELECT
    SaleYear AS Year__,
    SaleMonth AS Month__,
    TotalSales
FROM
    lowedtdslesMonths
WHERE
    SalesRank = 1
ORDER BY
    SaleYear, SaleMonth

	-- total sales for each sub-channel in each country, 
	--and then find the country with the highest total sales for each sub-channel.

	WITH SubChannelSales AS (
    SELECT
        Country,
        Sub_channel,
        SUM(Sales) AS TotalSales
    FROM
        cleaned_pharma_data
    GROUP BY
        Country, Sub_channel
),
RankedCountries AS (
    SELECT
        Country,
        Sub_channel,
        TotalSales,
        ROW_NUMBER() OVER (PARTITION BY Sub_Channel ORDER BY TotalSales DESC) AS CountryRank
    FROM
        SubChannelSales
)

SELECT
    Country,
    Sub_channel,
    TotalSales
FROM
    RankedCountries
WHERE
    CountryRank = 1
ORDER BY
    Sub_channel;





