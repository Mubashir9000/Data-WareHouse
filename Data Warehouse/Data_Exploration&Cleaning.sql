--DATA EXPLORATION
select * from MonCinema.booking_mode;
desc moncinema.booking_mode;

select * from MonCinema.cinema;
desc moncinema.cinema;
select count(distinct(cinema_id)),count(cinema_id) from MonCinema.cinema;

select * from MonCinema.cinema_rating;
desc moncinema.cinema_rating;
select count(distinct(rating_id)), count(rating_id) from moncinema.cinema_rating;
select * from MonCinema.cinema_rating where cinema_id not in (select distinct(cinema_id) from MonCinema.cinema);
--Cinema rating table contains a cinema id "75" that is not in the cinema table

select * from MonCinema.customer;
desc moncinema.customer;
select count(distinct(cust_id)),count(cust_id) from MonCinema.customer;

select * from MonCinema.genre;
desc moncinema.genre;
select count(distinct(genre_id)), count(genre_description) from MonCinema.genre;
select * from moncinema.genre where genre_id is NULL;
--Genre table has null id for "Undefined" genre description

select * from MonCinema.movie;
desc moncinema.movie;
select count(distinct(movie_id)),count(movie_id) from MonCinema.movie;
select movie_id from moncinema.movie group by movie_id having count(movie_id) > 1;
select * from moncinema.movie where movie_id = 317;
--Movie table has duplicate records of movie id "317"
select * from moncinema.movie where movie_spoken_language is NULL;
select * from moncinema.movie where movie_runtime < 0;


select * from MonCinema.movie_cinema;
desc moncinema.movie_cinema;
select * from MonCinema.movie_cinema where cinema_id not in (select distinct(cinema_id) from MonCinema.cinema);
select * from moncinema.cinema where cinema_id = 987;
select * from MonCinema.movie_cinema where movie_id not in (select distinct(movie_id) from MonCinema.movie);
select * from moncinema.movie where movie_id = 1234; 
--Movie cinema table has cinema id "987" that does not exist in cinema table and movie id "1234" that does not exist in movie table

select * from MonCinema.movie_company;
desc moncinema.movie_company;
select * from MonCinema.movie_company where movie_id not in (select distinct(movie_id) from MonCinema.movie);
select * from moncinema.movie where movie_id = 1233;
--Movie company table has movie id "1233" that does not exist in movie table


select * from MonCinema.movie_genre;
desc moncinema.movie_genre;
select movie_id from MonCinema.movie_genre where movie_id not in (select distinct(movie_id) from MonCinema.movie);
select genre_id from MonCinema.movie_genre where genre_id not in (select distinct(genre_id) from MonCinema.genre);

select * from MonCinema.production_company;
desc moncinema.production_company;
select count(distinct(company_id)), count(company_id) from MonCinema.production_company;
--Production company table has duplicate records of company id "18880"
select company_id from moncinema.production_company group by company_id having count(company_id) > 1;
select * from moncinema.production_company where company_id = 18880;

select * from MonCinema.review;
desc moncinema.review;
select count(distinct(review_id)), count(review_id) from MonCinema.review;
select movie_id from MonCinema.review where movie_id not in (select distinct(movie_id) from MonCinema.movie);
select * from Moncinema.review where to_date(to_char(review_date, 'YYYY'), 'YYYY') > to_date(2021, 'YYYY');
select * from moncinema.review where review_score > 5 or review_score < 0;
--Review table has review contains review score of -9, review id "1869"

select * from MonCinema.sale;
desc moncinema.sale;
select count(distinct(sale_id)), count(sale_id) from MonCinema.sale;
select mode_id from MonCinema.sale where mode_id not in (select distinct(mode_id) from MONCINEMA.booking_mode);
select cust_id from MonCinema.customer where cust_id not in (select distinct(cust_id) from moncinema.customer);
select cinema_id from moncinema.cinema where cinema_id not in (select distinct(cinema_id) from moncinema.customer);
select movie_id from moncinema.movie where movie_id not in (select distinct(movie_id) from moncinema.movie);
select staff_no from moncinema.staff where staff_no not in (select distinct(staff_no) from moncinema.staff);
select sale_id, staff_no from moncinema.sale where mode_id != 1 and staff_no = NULL;
select sale_id, sale_number_of_tickets, sale_total_price, sale_number_of_tickets*sale_unit_price from moncinema.sale where sale_total_price != sale_number_of_tickets*sale_unit_price;
--Sale table has sale total price does not match with sale_number_of_tickets*sale_unit_price, sale id "2500"
select s.movie_id, sale_date, movie_release_date from moncinema.sale s, moncinema.movie m where s.movie_id = m.movie_id and sale_date < movie_release_date;
select * from Moncinema.sale where to_date(to_char(sale_date, 'YYYY'), 'YYYY') > to_date(2021, 'YYYY');
select * from moncinema.movie where movie_id = 225;
-- The sale table has a sale that the date is on the year of 2050

select * from MonCinema.staff;
desc moncinema.staff;

--DATA CLEANING
drop table booking_mode;
create table booking_mode as select * from moncinema.booking_mode;
drop table cinema;
create table cinema as select * from moncinema.cinema;
drop table cinema_rating;
create table cinema_rating as select * from moncinema.cinema_rating;
drop table customer cascade constraints;
create table customer as select * from moncinema.customer;
drop table genre;
create table genre as select * from moncinema.genre;
drop table movie;
create table movie as select * from moncinema.movie;
drop table movie_cinema;
create table movie_cinema as select * from moncinema.movie_cinema;
drop table movie_company;
create table movie_company as select * from moncinema.movie_company;
drop table movie_genre;
create table movie_genre as select * from moncinema.movie_genre;
drop table production_company;
create table production_company as select * from moncinema.production_company;
drop table review;
create table review as select * from moncinema.review;
drop table sale;
create table sale as select * from moncinema.sale;
drop table staff;
create table staff as select * from moncinema.staff;


--Cinema rating table contains a cinema id "75" that is not in the cinema table
drop table cinema_rating;
create table cinema_rating as select * from moncinema.cinema_rating where cinema_id != 75;
select * from cinema_rating where cinema_id not in (select distinct(cinema_id) from cinema);


--Genre table has null id for "Undefined" genre description
drop table genre;
create table genre as select * from moncinema.genre;
delete from genre where genre_description = 'Undefined';
select * from genre where genre_description = 'Undefined';

--Movie table has duplicate records of movie id "317"
drop table movie;
create table movie as select distinct(movie_id) as movie_id, movie_name, movie_release_date, movie_spoken_language, movie_runtime from moncinema.movie;
select * from movie where movie_id = '317';

--Movie cinema table has cinema id "987" that does not exist in cinema table
--Movie cinema table has movie id "1234" that does not exist in movie table
drop table movie_cinema;
create table movie_cinema as select * from moncinema.movie_cinema where cinema_id != 987 and movie_id != 1234;
select * from movie_cinema where cinema_id = 987;
select * from movie_cinema where cinema_id = 1234;

--Movie company table has movie id "1233" that does not exist in movie table
drop table movie_company;
create table movie_company as select * from moncinema.movie_company where movie_id != 1233;
select * from movie_company where movie_id = 1233;

--Production company table has duplicate records of company id "18880"
drop table production_company;
create table production_company as select distinct(company_id) as company_id, company_name, company_address from moncinema.production_company;
select * from production_company where company_id = 18880;

--Review table has review contains review score of -9, review id "1869"
drop table review;
create table review as select * from moncinema.review where review_score > 0;
select * from review where review_score < 0;

--Sale table has sale total price does not match with sale_number_of_tickets*sale_unit_price, sale id "2500"
drop table sale;
create table sale as select * from moncinema.sale where to_date(to_char(sale_date, 'YYYY'), 'YYYY') <= to_date(2021, 'YYYY');
delete from sale where sale_id = 2500;
select sale_id, sale_number_of_tickets, sale_total_price, sale_number_of_tickets*sale_unit_price from sale where sale_id = 2500;
select * from sale where sale_id = 2501;


