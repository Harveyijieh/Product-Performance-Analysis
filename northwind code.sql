-- database tables
SELECT
  table_name
FROM
  information_schema.tables
WHERE
  table_schema = 'public';
 
---------------------------------------------------------------------------
-- Top Products By Revenue
select p.product_name, 
round(sum(ord.unit_price * ord.quantity):: numeric,2) as total_revenue
from products p
join order_details ord
on p.product_id = ord.product_id
group by p.product_name
order by total_revenue desc
limit 10;

-----------------------------------------------------------------------------
-- Top Selling Products
select p.product_name, sum(ord.quantity) as quantity_sold
from products p
join order_details ord
on p.product_id = ord.product_id
group by p.product_name
order by quantity_sold desc
limit 10;

-----------------------------------------------------------------------------
-- Top Category By Order and Revenue
SELECT 
    cat.category_name,
    COUNT(od.order_id) AS total_orders,
	round(sum(od.quantity * od.unit_price):: numeric,2) as total_revenue
FROM 
    categories cat
JOIN 
    products p ON cat.category_id = p.category_id
JOIN 
    order_details od ON p.product_id = od.product_id
GROUP BY 
    cat.category_name
ORDER BY 
    total_orders DESC;
---------------------------------------------------------------------------	
-- Customers with the Highest Orders
SELECT 
    c.customer_id, 
    c.company_name, 
    COUNT(o.order_id) AS total_orders, 
    round(SUM(od.unit_price * od.quantity * (1 - od.discount)):: numeric,2) AS total_revenue
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
JOIN 
    order_details od ON o.order_id = od.order_id
GROUP BY 
    c.customer_id, c.company_name
ORDER BY 
    total_orders DESC, total_revenue DESC
LIMIT 10;

--------------------------------------------------------------------------
-- umulative Revenue for Each Category
SELECT 
    cat.category_name, 
    p.product_name, 
    round(SUM(ord.quantity * ord.unit_price):: numeric,2) AS total_revenue,
    round(SUM(SUM(ord.quantity * ord.unit_price)) OVER (PARTITION BY cat.category_name ORDER BY SUM(ord.quantity * ord.unit_price)DESC):: numeric,2)  AS cumulative_revenue
FROM 
    products p
JOIN 
    categories cat ON p.category_id = cat.category_id
JOIN 
    order_details ord ON p.product_id = ord.product_id
GROUP BY 
    cat.category_name, p.product_name
ORDER BY 
    cat.category_name, cumulative_revenue;
