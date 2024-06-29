use pizzadb;

-- Basic:
-- Retrieve the total number of orders placed.
SELECT 
    count(order_id) as total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
select sum(order_details.quantity * pizzas.price) as total_revenue
from order_details
join pizzas on order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
select name, pizzas.price
from pizzas
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by price desc
limit 1;

-- Identify the most common pizza size ordered.
select size, count(order_details_id)
from pizzas
join order_details on order_details.pizza_id = pizzas.pizza_id
group by size
order by size;

-- List the top 5 most ordered pizza types along with their quantities.
select name, sum(quantity)
from pizzas
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by name
order by sum(quantity) desc
limit 5;

-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
select category, sum(quantity)
from pizzas
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by category
order by sum(quantity) desc;

-- Determine the distribution of orders by hour of the day.
select hour(order_time), count(order_id) from orders group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name)
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select order_date, count(order_id)
from orders
group by order_date;

-- Determine the top 3 most ordered pizza types based on revenue.
select name, sum(order_details.quantity * pizzas.price) as total_revenue
from order_details
join pizzas on order_details.pizza_id = pizzas.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders on orders.order_id = order_details.order_id
group by name order by total_revenue desc limit 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    (SUM(order_details.quantity * pizzas.price) / total_revenue.total * 100) AS total_revenue
FROM
    order_details
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    JOIN orders ON orders.order_id = order_details.order_id
    CROSS JOIN (
        SELECT SUM(order_details.quantity * pizzas.price) AS total
        FROM order_details
        JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    ) AS total_revenue
GROUP BY pizza_types.category, total_revenue.total
ORDER BY total_revenue DESC;


-- Analyze the cumulative revenue generated over time.
select order_date, sum(total_revenue) over(order by order_date) as cumulative_revenue
from (
	select orders.order_date, sum(order_details.quantity * pizzas.price) as total_revenue
    from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id
    join orders on orders.order_id = order_details.order_id
    group by orders.order_date
) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, total_revenue
FROM (
    SELECT category, name, total_revenue,
           RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS revenue_rank
    FROM (
        SELECT pizza_types.category, pizza_types.name,
               SUM(order_details.quantity * pizzas.price) AS total_revenue
        FROM pizza_types
        JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY pizza_types.category, pizza_types.name
    ) AS a
) AS b
WHERE revenue_rank <= 3;

















