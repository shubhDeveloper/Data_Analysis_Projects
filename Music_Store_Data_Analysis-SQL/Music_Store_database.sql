-- Question Set 1 - Basic

-- 1. Who is the senior most employee based on job title?
select * from employee 
order by levels desc
limit 1;
/

-- 2. Which contries have the most invoices?
select billing_country,count(invoice_id) as cnt from invoice 
group by (billing_country)
order by cnt desc
limit 1;
/

-- 3. What are top 3 values of total invoices?
select total from invoice order by total desc limit 3;
/

/* 4. Which city has the best customers. we would like to throw a promptional music festival 
in the city we made the most money. write a query that returns one city that has the highest 
sum of invoices totals.returns both the city name and sum of all invoice total. */

select billing_city,sum(total) t from invoice 
group by billing_city order by t desc;
/

/* 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
write a query that returns the person who has spent the most money. */

select c.customer_id,c.first_name,c.last_name,sum(i.total) total
from customer c inner join invoice i on c.customer_id = i.customer_id
group by (c.customer_id) order by total desc
limit 1;
/

-- Question Set 2 - Moderate

/* 1. Write a query to return the email, first_name, last_name, and Genre of all Rock Music listners.
Return your list ordered alphabetically by email starting with a */

select distinct c.first_name,c.last_name,c.email,g.name from 
customer c inner join invoice inc on c.customer_id = inc.customer_id
inner join invoice_line il on inc.invoice_id = il.invoice_id
inner join track t on t.track_id = il.track_id
inner join genre g on g.genre_id = t.genre_id
where g.name = 'Rock' 
order by c.email;
/

/* 2. Let's invite the artist who have written the most rock music in our dataset. write a query that 
returns the artist name and total track count of the top 10 rock bands. */

select ar.artist_id,ar.name,count(tr.track_id) total
from artist ar inner join album al on ar.artist_id = al.artist_id
inner join track tr on tr.album_id = al.album_id
inner join genre ge on tr.genre_id = ge.genre_id
where ge.name = 'Rock'
group by (ar.artist_id)
order by total desc
limit 10;
/

/* 3. Return all the track names that have a song length longer than the average song length return the name and 
milliseconds for each track. Order by the song length with the largest song listed first. */

select name, milliseconds from track where milliseconds >
(select avg(milliseconds)
from track)
order by milliseconds desc
/

-- Question Set 3 - Advance

/* 1. Find how much amount spent by each customer on artists? Write a query to return customer name,
artist_name and total spent. */

select * from artist;
select * from customer;
 
with best_selling_artist as (
    Select artist.artist_id as artist_id,artist.name as artist_name,
	SUM(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	inner join track on track.track_id = invoice_line.track_id
	inner join album on album.album_id = track.album_id
	inner join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
)
Select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
SUM(il.unit_price*il.quantity) as amount_spent
from invoice i 
inner join customer c on c.customer_id = i.customer_id
inner join invoice_line il on il.invoice_id = i.invoice_id
inner join track t on t.track_id = il.track_id 
inner join album alb on alb.album_id = t.album_id
inner join best_selling_artist bsa on bsa.artist_id = alb.artist_id 
group by 1,2,3,4
order by 5 desc;
/

/* 2. We want to find out the most popular music genre for each contry. we determine the most popular 
genre as genre with the highest amount of purchases. write a query that returns each contry along with 
the top genre. For countries whrere the maximum number of purchases is shared return all genre. */

with popular_genre as 
(
    select count(invoice_line.quantity) as purcheses,customer.country,genre.name,genre.genre_id,
	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rowNo
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where rowNo <= 1
