create database music;

use music;

create table employee(
employee_id int primary key,
last_name varchar(50),
first_name varchar(50),
title varchar(50),
reports_to int,
levels varchar(50),
birthdate varchar(50),
hire_date varchar(50),
address varchar(50),
city varchar(50),
state varchar(50),
country varchar(50),
postal_code varchar(50),
phone varchar(50),
tax varchar(50),
email varchar(50)
);

select * from employee;

create table customer(
customer_id int primary key,
first_name varchar(50),
last_name varchar(50),
company varchar(50),
address varchar(50),
city varchar(50),
state varchar(50),
country varchar(50),
postal_code varchar(50),
phone varchar(50),
tax varchar(50),
email varchar(50),
support_rep_id int,
foreign key (support_rep_id) references employee(employee_id)
);

select * from customer;

create table invoice(
invoice_id int primary key,
customer_id int,
invoice_date varchar(50),
billing_address varchar(50),
billing_city varchar(50),
billing_state varchar(50),
billing_country varchar(50),
billing_postal_code varchar(50),
total float,
foreign key (customer_id) references customer(customer_id)
);

select * from invoice;

create table invoice_line(
invoice_line_id int primary key,
invoice_id int,
track_id int,
unit_price float,
quantity int,
foreign key (invoice_id) references invoice(invoice_id),
foreign key (track_id) references track(track_id)
);

select * from invoice_line;

create table playlist(
playlist_id int primary key,
name varchar(50)
);

select * from playlist;

create table artist(
artist_id int primary key,
name varchar(50)
);

select * from artist;

create table album(
album_id int primary key,
title varchar(50),
artist_id int,
foreign key (artist_id) references artist(artist_id)
);

select * from album;

create table media_type(
media_type_id int primary key,
name varchar(50)
);

select * from media_type;

create table genre(
genre_id int primary key,
name varchar(50)
);

select * from genre;

create table track(
track_id int primary key,
name varchar(50),
album_id int,
media_type_id int,
genre_id int,
composer varchar(50),
milliseconds int,
bytes int,
unit_price float,
foreign key (album_id) references album(album_id),
foreign key (media_type_id) references media_type(media_type_id),
foreign key (genre_id) references genre(genre_id)
); 

select * from track;

create table playlist_track(
playlist_id int,
track_id int,
foreign key (playlist_id) references playlist(playlist_id),
foreign key (track_id) references track(track_id)
);

select * from playlist_track;

-- 1. Who is the senior most employee based on job title?

select first_name,title,levels
from employee
order by levels desc
limit 1;

-- 2. Which countries have the most Invoices?

select billing_country,count(invoice_id) as 'No of Invoice'
from invoice
group by billing_country
order by count(invoice_id) desc;

-- 3.What are top 3 values of total invoice?

select billing_country,count(invoice_id) as 'No of Invoice'
from invoice
group by billing_country
order by count(invoice_id) desc
limit 3;

/* 4.Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice totals*/

select billing_city, count(invoice_id) as 'total no of invoice',sum(total) as 'total'
from invoice
group by billing_city
order by count(invoice_id) desc
limit 1;

/* 5.Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money */

select customer.customer_id, first_name, last_name,count(invoice_id), SUM(invoice.total) AS 'total spending'
from customer
join invoice 
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by SUM(invoice.total) desc
limit 1;

 /* 6.Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
 Return your list ordered alphabetically by email starting with A */
 
 # Method 1 :
 
 select distinct email,first_name,last_name,genre.name as genre_name
 from customer
 join invoice on customer.customer_id = invoice.customer_id
 join invoice_line on invoice.invoice_id = invoice_line.invoice_id
 join track on track.track_id = invoice_line.track_id
 join genre on track.genre_id = genre.genre_id
 where genre.name = 'rock'
 order by email ;

# Method 2:

select distinct email,first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email;

/* 7. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */

select distinct artist.name,count(album.album_id) as no_of_track, genre.name
from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
where genre.name = 'rock'
group by artist.name
order by count(album.album_id) desc
limit 10;

/* 8. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */

select name,milliseconds
from track
where milliseconds >(select avg(milliseconds) as avg_sound 
from track) 
order by milliseconds desc;

/* 9. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */

# Method 1

select distinct artist.name as Artist_name, customer.first_name as Customer_name, sum(invoice_line.unit_price*invoice_line.quantity) as Total_spend
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on artist.artist_id = album.artist_id
group by artist.name,customer.first_name
order by sum(invoice_line.unit_price*invoice_line.quantity) desc;

# Method 2

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* 10.We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

#OR

WITH GenrePurchaseCounts AS (
    SELECT 
        customer.country,
        genre.name AS Genre_Name,
        COUNT(invoice_line.quantity) AS PurchaseCount
    FROM customer
    JOIN invoice ON customer.customer_id = invoice.customer_id
    JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
    JOIN track ON invoice_line.track_id = track.track_id
    JOIN genre ON track.genre_id = genre.genre_id
    GROUP BY customer.country, genre.name
),
RankedGenres AS (
    SELECT 
        country,
        Genre_Name,
        PurchaseCount,
        RANK() OVER (PARTITION BY country ORDER BY PurchaseCount DESC) AS GenreRank
    FROM GenrePurchaseCounts
)
SELECT 
    country,
    Genre_Name,
    PurchaseCount
FROM RankedGenres
WHERE GenreRank = 1
ORDER BY country, Genre_Name;

/* 11.Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount*/

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;
