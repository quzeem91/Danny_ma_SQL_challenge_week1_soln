# Danny_ma_SQL_challenge_week1_soln
week 1 solution of Danny_ma's 8 weeks SQL challenge. Solution contains Beautiful written  SQL statements with easy readability.
![temp](https://8weeksqlchallenge.com/images/case-study-designs/1.png)

## Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen. <br>

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business. <br>

## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.
<br>
He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study:

* sales <br>
* menu <br>
* members <br>
You can inspect the entity relationship diagram and example data below.
## Entity Relationship Diagram

[!ERD](../ERD.jpg)


## Case Study Questions
---

1. **What is the total amount each customer spent at the restaurant?**

    SELECT s.customer_id,SUM(m.price)  "total_amt_spent($)"
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m
    ON m.product_id=s.product_id
    GROUP BY 1
    ORDER BY 2 DESC;

| customer_id | total_amt_spent($) |
| ----------- | ------------------ |
| A           | 76                 |
| B           | 74                 |
| C           | 36                 |

---
**Query #2**
**2. How many days has each customer visited the restaurant?**

    WITH unique_days_count as (
    SElECT DISTINCT s.customer_id ,s.order_date days
    FROM dannys_diner.sales s
    )
    
    SELECT customer_id ,COUNT(days) visitation_count
    FROM unique_days_count
    GROUP BY 1
    ORDER BY 1;

| customer_id | visitation_count |
| ----------- | ---------------- |
| A           | 4                |
| B           | 6                |
| C           | 2                |

---
**#3 What was the first item from the menu purchased by each customer?**

    WITH CTE1 as (
    SELECT DISTINCT s.Customer_id ,s.order_date, m.product_name 
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m
    ON m.product_id = s.product_id
    
    )
    SELECT customer_id ,product_name,MIN(order_date)first_date_order
    FROM CTE1
    GROUP BY 1,2 
    ORDER BY 3,1
    LIMIT 4 ;

| customer_id | product_name | first_date_order         |
| ----------- | ------------ | ------------------------ |
| A           | sushi        | 2021-01-01T00:00:00.000Z |
| A           | curry        | 2021-01-01T00:00:00.000Z |
| B           | curry        | 2021-01-01T00:00:00.000Z |
| C           | ramen        | 2021-01-01T00:00:00.000Z |

---


    SELECT s.Customer_id , m.product_name,MIN(s.order_date) first_date_order 
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m
    ON m.product_id = s.product_id
    GROUP BY 1, 2
    ORDER BY 3,1
    LIMIT 4;

| customer_id | product_name | first_date_order         |
| ----------- | ------------ | ------------------------ |
| A           | sushi        | 2021-01-01T00:00:00.000Z |
| A           | curry        | 2021-01-01T00:00:00.000Z |
| B           | curry        | 2021-01-01T00:00:00.000Z |
| C           | ramen        | 2021-01-01T00:00:00.000Z |

---
**Query #5**

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
    ORDER BY 1;

| customer_id | product_name | count |
| ----------- | ------------ | ----- |
| A           | ramen        | 3     |
| B           | ramen        | 2     |
| C           | ramen        | 3     |

---
**Query #6**

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

| customer_id | product_name | popularity_count |
| ----------- | ------------ | ---------------- |
| C           | ramen        | 3                |
| A           | ramen        | 3                |
| B           | sushi        | 2                |
| B           | curry        | 2                |
| B           | ramen        | 2                |

---
**Query #7**

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

| customer_id | product_name | first_order_date_as_a_member |
| ----------- | ------------ | ---------------------------- |
| A           | curry        | 2021-01-07T00:00:00.000Z     |
| B           | sushi        | 2021-01-11T00:00:00.000Z     |

---
**Query #8**

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

| customer_id | product_name | last_order_date_as_a_non_member |
| ----------- | ------------ | ------------------------------- |
| A           | sushi        | 2021-01-01T00:00:00.000Z        |
| A           | curry        | 2021-01-01T00:00:00.000Z        |
| B           | sushi        | 2021-01-04T00:00:00.000Z        |

---
**Query #9**

    SELECT s.Customer_id,SUM(m.price) "total_amt_Spent_before_becoming_a_member($)",  COUNT(m.product_id) number_of_orders
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m
    ON s.product_id=m.product_id
    JOIN dannys_diner.members mb
    ON  mb.customer_id=s.customer_id and s.order_date < mb.join_date  
    GROUP BY 1 
    ORDER BY 2 DESC ,1;

| customer_id | total_amt_Spent_before_becoming_a_member($) | number_of_orders |
| ----------- | ------------------------------------------- | ---------------- |
| B           | 40                                          | 3                |
| A           | 25                                          | 2                |

---
**Query #10**

    WITH CTE1 as(SELECT s.customer_id,CASE WHEN lower(m.product_name)='sushi' Then (m.price)*20 
    						ELSE  price*10 END AS points
    from dannys_diner.sales s
    JOIN dannys_diner.menu m 
    ON s.product_id=m.product_id)
    
    SELECT customer_id ,SUM(points) total_points
    FROM CTE1
    GROUP BY 1 
    ORDER BY  1 ;

| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |

---
**Query #11**

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
    
    SELECT customer_id ,SUM(points) total_january_points
    FROM CTE2
    GROUP BY 1
    ORDER BY 1;

| customer_id | total_january_points |
| ----------- | -------------------- |
| A           | 1020                 |
| B           | 320                  |

---
**Query #12**

    SELECT s.customer_id ,s.order_date, m.product_name ,m.price ,
    CASE WHEN s.customer_id=mb.customer_id AND s.order_date>= join_date THEN  'Y'
    ELSE 'N' END as Members 
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m
    ON s.product_id=m.product_id
    LEFT JOIN dannys_diner.members mb
    ON  mb.customer_id=s.customer_id
    ORDER By 1 , 2 ;

| customer_id | order_date               | product_name | price | members |
| ----------- | ------------------------ | ------------ | ----- | ------- |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N       |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N       |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y       |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y       |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N       |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N       |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N       |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y       |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y       |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y       |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N       |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N       |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N       |

---
**Query #13**

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
    
    
    FROM CTE1
    LEFT JOIN dannys_diner.members mb
    ON  mb.customer_id=CTE1.customer_id;

| customer_id | order_date               | product_name | price | members | ranking |
| ----------- | ------------------------ | ------------ | ----- | ------- | ------- |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N       | null    |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N       | null    |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y       | 1       |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y       | 2       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y       | 3       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y       | 3       |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N       | null    |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N       | null    |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N       | null    |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y       | 1       |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y       | 2       |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y       | 3       |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N       | null    |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N       | null    |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N       | null    |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/uthSoEVxg4heTzzgtTxU2y/0)
