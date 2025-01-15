create database pizzahut;
-- Basic:
-- Retrieve the total number of orders placed.
select count(order_id) from orders;
-- Calculate the total revenue generated from pizza sales.
select sum(quantity*price) as total_revenue from pizzas p 
join order_details od 
on p.pizza_id=od.pizza_id
join orders o 
on od.order_id=o.order_id;

-- Identify the highest-priced pizza.
select p.pizza_id,price as highest_price from order_details od 
join pizzas p 
on od.pizza_id=p.pizza_id
order by price desc
limit 1;

-- Identify the most common pizza size ordered.

select size,count(size) as common from pizzas 
group by size 
order by common desc
limit 1;
-- List the top 5 most ordered pizza types along with their quantities.
select size,count(size) as common from pizzas 
group by size 
order by common desc
limit 5;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.

select category,sum(quantity) as quantity_sum from pizza_types pt 
join pizzas p 
on pt.pizza_type_id = p.pizza_type_id 
join order_details od 
on p.pizza_id=od.pizza_id
group by category; 
-- Determine the distribution of orders by hour of the day.
select hour(time) as hour_of_day ,count(order_id) as order_count from orders
group by hour_of_day; 

-- Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) from pizza_types 
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(total_pizza),0) as avg_quantity from
(select date,sum(quantity) as total_pizza from orders o 
join order_details od 
on o.order_id=od.order_id 
group by date) as total; 
-- Determine the top 3 most ordered pizza types based on revenue.
select pt.pizza_type_id,sum(price * quantity) as revenue from pizza_types pt 
join pizzas p 
on pt.pizza_type_id=p.pizza_type_id 
join order_details od 
on p.pizza_id=od.pizza_id 
group by 1 
order by 2 desc 
limit 3;
-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
select category,(sum(quantity * price)/(select sum(price*quantity) from pizza_types pt 
join pizzas p 
on pt.pizza_type_id=p.pizza_type_id
join order_details od 
on p.pizza_id=od.pizza_id))*100 as revenue from pizza_types pt 
join pizzas p 
on pt.pizza_type_id=p.pizza_type_id
join order_details od 
on p.pizza_id=od.pizza_id
group by category;


-- Analyze the cumulative revenue generated over time.

select date,sum(sum(quantity*price)) over(order by date rows between unbounded preceding and current row) as cumulative_sum
from pizzas p 
join order_details od 
on p.pizza_id=od.pizza_id
join orders o 
on od.order_id=o.order_id
group by date;
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with mycte as(select category,name,sum(price * quantity) as revenue
from pizza_types pt 
join pizzas p 
on pt.pizza_type_id=p.pizza_type_id 
join order_details od 
on p.pizza_id=od.pizza_id
group by category,name
order by revenue),
newct as(
select category,name,rank() over(partition by category order by revenue desc) as rn from mycte)
select category,name,rn from newct
where rn<=3;

