-- REVENUE INSIGHTS



-- 1. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(
        SUM(order_details.quantity * pizzas.price) /
        (SELECT 
            SUM(order_details.quantity * pizzas.price)
         FROM
            order_details
                INNER JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id
        ) * 100,
        2
    ) AS revenue_percentage
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;



-- 2. Analyze the cumulative revenue generated over time.

SELECT 
    order_date,
    SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM
    (SELECT 
        orders.order_date,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM
        order_details
            INNER JOIN
        pizzas ON order_details.pizza_id = pizzas.pizza_id
            INNER JOIN
        orders ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS sales;



-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
    category, 
    name AS pizza_name, 
    revenue
FROM
    (SELECT 
        category, 
        name, 
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM
        (SELECT 
            pizza_types.category, pizza_types.name,
            SUM(order_details.quantity * pizzas.price) AS revenue
        FROM
            pizza_types
                INNER JOIN
            pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
                INNER JOIN
            order_details ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY
            pizza_types.category,
            pizza_types.name) AS a) AS b
WHERE
    rn <= 3;
