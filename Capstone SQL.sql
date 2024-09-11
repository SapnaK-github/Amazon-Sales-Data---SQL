Create DataBase Amazon;
Use Amazon;

CREATE TABLE Sales_Data_Of_Amazon (
    invoice_id VARCHAR(30) Not Null,
    branch VARCHAR(5) Not Null,
    city VARCHAR(30) Not Null,
    customer_type VARCHAR(30) Not Null,
    gender VARCHAR(10) Not Null,
    product_line VARCHAR(100) Not Null,
    unit_price DECIMAL(10,2) Not Null,
    quantity INT Not Null,
    VAT FLOAT(6,4) Not Null,
    total DECIMAL(10,2) Not Null,
    date DATE Not Null,
    time TIME Not Null,
    payment_method VARCHAR(20) Not Null,
    cogs DECIMAL(10,2) Not Null,
    gross_margin_percentage FLOAT(11,9) Not Null,
    gross_income DECIMAL(10,2) Not Null,
    rating FLOAT(6,4)  Not Null
);

drop table Sales_Data_Of_Amazon;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Amazon.csv'
INTO TABLE Sales_Data_Of_Amazon
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'secure_file_priv';

Select * from Sales_Data_Of_Amazon;

-- Feature Engineering
-- Add new column as timeofday
Alter table Sales_Data_Of_Amazon
Add column timeofday VARCHAR(10);

SET SQL_SAFE_UPDATES = 0;

Update Sales_Data_Of_Amazon
SET timeofday = "Morning"
Where time < "12:00:00";

Update Sales_Data_Of_Amazon
SET timeofday = "Afternoon"
Where time between "12:00:00" AND "17:00:00";

Update Sales_Data_Of_Amazon
SET timeofday = "Evening"
Where time > "17:00:00";

select * from Sales_Data_Of_Amazon;

-- Add new column as dayname 
Alter table Sales_Data_Of_Amazon
Add column dayname VARCHAR(10);

Update Sales_Data_Of_Amazon
SET dayname = dayname(date);

-- Add new column as monthname  
Alter table Sales_Data_Of_Amazon
Add column monthname VARCHAR(15);

Update Sales_Data_Of_Amazon
SET monthname = monthname(date);

-- Exploratory Data Analysis (EDA)

Select count(*) as total_rows from Sales_Data_Of_Amazon;

Show columns from Sales_Data_Of_Amazon;

-- Total Sales by Product Line
Select product_line, SUM(total) AS total_sales from Sales_Data_Of_Amazon group by product_line;

-- Average Customer Satisfaction by Product Line
Select product_line, avg(rating) as avg_satisfaction from Sales_Data_Of_Amazon group by product_line;

-- Total Sales by Customer_Type
Select customer_type, sum(total) as total_sale from Sales_Data_Of_Amazon group by customer_type;

-- Business Questions To Answer:

-- Question 1. What is the count of distinct cities in the dataset?
-- Answer 1.
Select count(distinct(city)) as distinct_city_count from Sales_Data_Of_Amazon;

-- Question 2. For each branch, what is the corresponding city?
-- Answer 2.
Select distinct(branch), city from Sales_Data_Of_Amazon;

-- Question 3. What is the count of distinct product lines in the dataset?
-- Answer 3.
Select count(distinct(product_line)) as product_lines_count from Sales_Data_Of_Amazon;

-- Question 4. Which payment method occurs most frequently?
-- Answer 4.
Select max(payment_method), count(payment_method) as count from Sales_Data_Of_Amazon
group by payment_method order by count desc limit 1;

-- Question 5. Which product line has the highest sales?
-- Answer 5.
Select product_line, SUM(quantity) as Sale from Sales_Data_Of_Amazon
group by product_line order by Sale desc limit 1;

-- Question 6. How much revenue is generated each month?
-- Answer 6.
Select sum(total), monthname from Sales_Data_Of_Amazon group by monthname;

-- Question 7. In which month did the cost of goods sold reach its peak?
-- Answer 7.
Select monthname, sum(cogs) as sum_cogs from Sales_Data_Of_Amazon
group by monthname order by sum_cogs desc limit 1;

-- Question 8. Which product line generated the highest revenue?
-- Answer 8. 
Select product_line, SUM(total) as highest_revenue from Sales_Data_Of_Amazon
group by product_line order by highest_revenue desc limit 1;

-- Question 9. In which city was the highest revenue recorded?
-- Answer 9.
Select city, sum(total) as highest_revenue from Sales_Data_Of_Amazon
group by city order by highest_revenue desc limit 1;

-- Question 10. Which product line incurred the highest Value Added Tax?
-- Answer 10.
Select product_line, Sum(VAT) as highest_VAT from Sales_Data_Of_Amazon
group by product_line order by highest_VAT desc limit 1;

-- Question 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
-- Answer 11. 
Select product_line, sum(quantity),
case
when sum(quantity) > (Select sum(quantity)/count(distinct(product_line)) from Sales_Data_Of_Amazon) then "Good"
else "Bad"
END Good_Bad from Sales_Data_Of_Amazon group by product_line;


-- Question 12. Identify the branch that exceeded the average number of products sold.
-- Answer 12.
Select branch, avg(quantity) as avg_quantity from Sales_Data_Of_Amazon 
group by branch order by avg_quantity desc limit 1;

-- Question 13. Which product line is most frequently associated with each gender?
-- Answer 13. 
With cte as (
Select product_line, gender, SUM(quantity) as sum_quantity,
row_number() over(partition by gender order by SUM(quantity) desc) 
as cpl from Sales_Data_Of_Amazon
group by gender,product_line
)
Select product_line, gender, sum_quantity from cte where cpl = 1;


-- Question 14. Calculate the average rating for each product line.
-- Answer 14.
Select avg(rating) as avg_rating, product_line from Sales_Data_Of_Amazon
group by product_line order by avg_rating;

-- Question 15. Count the sales occurrences for each time of day on every weekday.
-- Answer 15.
Select count(quantity) as sales_occurrences, timeofday, dayname from Sales_Data_Of_Amazon
group by timeofday, dayname having dayname != 'saturday' and dayname != 'sunday' order by sales_occurrences desc;

-- Question 16. Identify the customer type contributing the highest revenue.
-- Answer 16.
Select customer_type, sum(total) as highest_revenue from Sales_Data_Of_Amazon
group by customer_type order by highest_revenue desc limit 1;

-- Question 17. Determine the city with the highest VAT percentage.
-- Answer 17.
Select city, sum(VAT)/(Select sum(VAT) from Sales_Data_Of_Amazon)*100 as highest_VAT_percentage 
from Sales_Data_Of_Amazon group by city order by highest_VAT_percentage desc limit 1;


-- Question 18. Identify the customer type with the highest VAT payments.
-- Answer 18.
Select customer_type, sum(VAT) as highest_VAT_payments from Sales_Data_Of_Amazon
group by customer_type order by highest_VAT_payments desc limit 1;

-- Question 19. What is the count of distinct customer types in the dataset?
-- Answer 19.
Select count(distinct(customer_type)) as count_of_distinct_customer from Sales_Data_Of_Amazon;

-- Question 20. What is the count of distinct payment methods in the dataset?
-- Answer 20.
Select count(distinct(payment_method)) as count_distinct_payment_methods from Sales_Data_Of_Amazon;

-- Question 21. Which customer type occurs most frequently?
-- Answer 21. 
Select count(customer_type), customer_type from Sales_Data_Of_Amazon
group by customer_type limit 1;

-- Question 22. Identify the customer type with the highest purchase frequency.
 -- Answer 22.
Select customer_type, sum(quantity) as sum_quantity from Sales_Data_Of_Amazon
group by customer_type order by sum_quantity desc limit 1; 

-- Question 23. Determine the predominant gender among customers.
-- Answer 23.
Select count(gender) as max_gender, gender from Sales_Data_Of_Amazon
group by gender order by max_gender desc limit 1;

-- Question 24. Examine the distribution of genders within each branch.
-- Answer 24. 
Select count(gender), gender, branch from Sales_Data_Of_Amazon
group by gender, branch;

-- Question 25. Identify the time of day when customers provide the most ratings.
-- Answer 25.
Select timeofday, count(rating) as most_ratings from Sales_Data_Of_Amazon
group by timeofday order by most_ratings desc;

-- Question 26. Determine the time of day with the highest customer ratings for each branch.
-- Answer 26.
With cte as (
Select timeofday, branch, sum(rating) as count_rating,
Row_number() over(partition by branch order by  sum(rating) desc) as highest_rating from 
Sales_Data_Of_Amazon group by branch, timeofday order by count_rating)
select timeofday, branch, count_rating from cte where highest_rating = 1;

-- Question 27. Identify the day of the week with the highest average ratings.
-- Answer 27.
Select dayname, avg(rating) as avg_rating from Sales_Data_Of_Amazon
group by dayname order by avg_rating desc limit 1;


-- Question 28. Determine the day of the week with the highest average ratings for each branch.
-- Answer 28.
With cte as (
Select dayname, branch, avg(rating) as avg_rating, row_number() over(partition by branch order by
avg(rating) desc) as  highest_avg_rating from Sales_Data_Of_Amazon group by branch, dayname)
select dayname, branch, avg_rating from cte where highest_avg_rating = 1;



