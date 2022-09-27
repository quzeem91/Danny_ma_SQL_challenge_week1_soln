1-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id,SUM(m.price)
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON m.product_id=s.product_id
GROUP BY 1
ORDER BY 2 DESC;

-- 2. How many days has each customer visited the restaurant?

WITH CTE1 as (
SElECT DISTINCT s.customer_id ,s.order_date days
FROM dannys_diner.sales s
)

SELECT customer_id ,COUNT(days) visitation_count
FROM CTE1
GROUP BY 1
ORDER BY 1;


-- 3. What was the first item from the menu purchased by each customer?

WITH CTE1 as (
SELECT DISTINCT s.Customer_id ,s.order_date, m.product_name 
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON m.product_id = s.product_id
--ORDER BY 2,3,1 
)
SELECT customer_id ,product_name,MIN(order_date)first_date_order
FROM CTE1
GROUP BY 1,2 
ORDER BY 3,1
LIMIT 4 ;

-- 3. What was the first item from the menu purchased by each customer?

SELECT s.Customer_id , m.product_name,MIN(s.order_date) first_date_order 
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON m.product_id = s.product_id
GROUP BY 1, 2
ORDER BY 3,1
LIMIT 4;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

WITH CTE1 as (
SELECT m.product_name, COUNT(m.product_name),SUM(PRICE)
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id=m.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1 
)

SELECT s.customer_id,m.product_name ,COUNT(m.product_name)
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id=m.product_id
WHERE m.product_name= (SELECT product_name FROM CTE1)
GROUP BY 1,2
ORDER BY 3 DESC;


-- 5. Which item was the most popular for each customer?
WITH CTE1 as ( 
SELECT s.customer_id ,m.product_name, COUNT(m.product_name) popularity_count
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id=m.product_id
GROUP BY 1,2 
) ,
CTE2 as (
SELECT CTE1.customer_id, MAX(CTE1.popularity_count) popularity_count
FROM CTE1
GROUP BY 1
)

SELECT  CTE1.customer_id ,CTE1.product_name, CTE1.popularity_count
FROM CTE1 
JOIN CTE2
ON CTE1.customer_id = CTE2.customer_id AND CTE1.popularity_count = CTE2.popularity_count
ORDER BY 3 DESC;

-- 6. Which item was purchased first by the customer after they became a member?

WITH CTE1 as (
SELECT mb.Customer_id,m.product_name ,s.order_date
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id=m.product_id
JOIN dannys_diner.members mb
ON  mb.customer_id=s.customer_id and s.order_date >= mb.join_date  
), CTE2 as (
SELECT customer_id ,MIN(order_date) order_date
FROM CTE1 
GROUP BY 1 
)
SELECT CTE2.customer_id ,m.product_name, CTE2.order_date first_order_date_as_a_member
FROM dannys_diner.sales s
JOIN CTE2 
ON CTE2.customer_id=s.customer_id AND CTE2.order_date=s.order_date
JOIN dannys_diner.menu m
ON  s.product_id=m.product_id 
ORDER BY 1;

-- 7. Which item was purchased just before the customer became a member?

WITH CTE1 as (
SELECT mb.Customer_id,m.product_name ,s.order_date
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id=m.product_id
JOIN dannys_diner.members mb
ON  mb.customer_id=s.customer_id and s.order_date < mb.join_date  
), CTE2 as (
SELECT customer_id ,MAX(order_date) order_date
FROM CTE1 
GROUP BY 1 
)
SELECT CTE2.customer_id ,m.product_name, CTE2.order_date last_order_date_as_a_non_member
FROM dannys_diner.sales s
JOIN CTE2 
ON CTE2.customer_id=s.customer_id AND CTE2.order_date=s.order_date
JOIN dannys_diner.menu m
ON  s.product_id=m.product_id 
ORDER BY 1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.Customer_id,SUM(m.price) total_amt_Spent_before_becoming_a_member,  COUNT(m.product_id) number_of_orders
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id=m.product_id
JOIN dannys_diner.members mb
ON  mb.customer_id=s.customer_id and s.order_date < mb.join_date  
GROUP BY 1 
ORDER BY 2 DESC ,1;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH CTE1 as(
SELECT s.customer_id,
CASE WHEN lower(m.product_name)='sushi' Then (m.price)*20 
						ELSE  price*10 END AS points
from dannys_diner.sales s
JOIN dannys_diner.menu m 
ON s.product_id=m.product_id)

SELECT customer_id ,SUM(points) total_points
FROM CTE1
GROUP BY 1 
ORDER BY  1 ;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--not just sushi - how many points do customer A and B have at the end of January?

WITH CTE1 as (
SELECT s.customer_id , m.product_name,m.price ,s.order_date ,mb.join_date,(mb.join_date + integer '6')  first_week_order_date_as_a_member
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id=m.product_id
JOIN dannys_diner.members mb
ON  mb.customer_id=s.customer_id and (s.order_date >= mb.join_date AND  s.order_date < '2021-02-01')
 ), 
CTE2 as (SELECT customer_id , product_name,price,order_date ,join_date , 
   CASE WHEN order_date <= first_week_order_date_as_a_member  THEN 20 * price 
   WHEN order_date >first_week_order_date_as_a_member and lower(product_name)='sushi' THEN  20 * price 
   ELSE price *10 END as points 
   FROM CTE1 )

SELECT customer_id ,SUM(points)
FROM CTE2
GROUP BY 1
ORDER BY 1;


--Bonus Question 1 
SELECT s.customer_id ,s.order_date, m.product_name ,m.price ,
CASE WHEN s.customer_id=mb.customer_id AND s.order_date>= join_date THEN  'Y'
ELSE 'N' END as Members 
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id=m.product_id
LEFT JOIN dannys_diner.members mb
ON  mb.customer_id=s.customer_id
ORDER By 1 , 2 ;
 


--Bonus Question 2
WITH CTE1 as (
SELECT s.customer_id ,s.order_date, m.product_name ,m.price ,
CASE WHEN s.customer_id=mb.customer_id AND s.order_date>= join_date THEN  'Y'
ELSE 'N' END as Members 
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id=m.product_id
LEFT JOIN dannys_diner.members mb
ON  mb.customer_id=s.customer_id
ORDER By 1 , 2)

SELECT CTE1.customer_id ,cte1.order_date,cte1.product_name,cte1.Price ,cte1.members ,
CASE WHEN CTE1.customer_id=mb.customer_id AND CTE1.order_date>= mb.join_date 
THEN  DENSE_RANK() OVER (PARTITION BY CTE1.customer_id,CTE1.members ORDER BY CTE1.order_date ) END as Ranking

--DENSE_RANK() OVER (PARTITION BY customer_id,members ORDER BY order_date ) as Ranking 
FROM CTE1
LEFT JOIN dannys_diner.members mb
ON  mb.customer_id=CTE1.customer_id 
 