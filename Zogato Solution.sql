drop database if exists zogato;
create database zogato;
use zogato;
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date);

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'2017-09-22-'),
(3,'2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,username varchar(20) ,signup_date date); 

INSERT INTO users(userid,username,signup_date) 
 VALUES (1,'Hamza','2014-09-02'),
(2,'Yashwant','2015-01-15'),
(3,'Dhanush','2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- 1. What is the total amount each customers spent on Zogato?
select
	u.userid, u.username, sum(p.price) as "Total Amount"
from
	users u
join
	sales s
    on u.userid = s.userid
join
	product p
	on s.product_id = p.product_id
group by u.userid, u.username;

-- 2. How many days has each customer visited Zogato ?
select
	u.userid, u.username, count(distinct s.created_date) as days_signedin
from
	users u
join
	sales s
    on u.userid = s.userid
group by
	u.userid, u.username;

-- 3. What was the first product purchased by each customer ?
select t.userid, t.username, t.product_name as first_purchased from
(select
	u.userid, u.username, p.product_name,
    dense_rank() over(partition by u.userid order by s.created_date) rank_product
from
	users u
join
	sales s
	on u.userid = s.userid
join
	product p
	on s.product_id = p.product_id) t
where t.rank_product = 1;

-- 4. What is the most purchsed item on menu and how many times was it purchased by all customers ?
select 
	u.userid,u.username, p.product_name most_purchased_item,count(s.product_id) times_purchased
from 
	users u, sales s, product p
where
	(u.userid = s.userid and s.product_id = p.product_id)
    and
    p.product_id = 
					(select
						s.product_id
					from
						sales s
					group by 
						s.product_id
					order by
						count(s.product_id) desc
					limit 1)
group by 
	u.userid,u.username, p.product_name;

-- 5. Which item was most popular for each customers ?
select
	u.username,max(p.product_name) most_popular_product, count(p.product_id) times_purchased
from
	sales s
join
	product p
    on s.product_id = p.product_id
join
	users u
    on s.userid = u.userid
where
	p.product_id in
		(select product_id from sales si where s.userid = si.userid)
group by u.username;

-- 6. Which Item was purchased first after they became a member ?
select 
	t.userid, t.username, t.gold_signup_date, t.created_date purchased_date, t.product_name 
from
	(select
		u.userid, u.username, g.gold_signup_date, s.created_date, p.product_name,
		dense_rank() over(partition by u.userid order by s.created_date asc) as dense_rank_created
	from
		users u
	join
		sales s
		on u.userid = s.userid
	join
		product p
		on s.product_id = p.product_id
	join
		goldusers_signup g
		on u.userid = g.userid
	where
		g.gold_signup_date <= s.created_date) t
where
	t.dense_rank_created = 1;
    
-- 7. Which item was just purchased before the customer became a member ?
select 
	t.userid, t.username, t.gold_signup_date, t.created_date purchased_date, t.product_name 
from
	(select
		u.userid, u.username, g.gold_signup_date, s.created_date, p.product_name,
		dense_rank() over(partition by u.userid order by s.created_date desc) as dense_rank_created
	from
		users u
	join
		sales s
		on u.userid = s.userid
	join
		product p
		on s.product_id = p.product_id
	join
		goldusers_signup g
		on u.userid = g.userid
	where
		g.gold_signup_date >= s.created_date) t
where
	t.dense_rank_created = 1;
    
-- 8. What is the total order and amount spent for each member before they became a member ?
select
	u.userid, u.username, count(s.created_date) "total orders",sum(p.price) as "total amount spent 
before becoming a member"
from
	users u
join
	sales s
    on u.userid = s.userid
join
	product p
    on s.product_id = p.product_id
join
	goldusers_signup g
    on u.userid = g.userid
where
	g.gold_signup_date > s.created_date
group by
	u.userid, u.username;
    
describe users;