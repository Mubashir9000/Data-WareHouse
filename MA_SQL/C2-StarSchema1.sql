--Season DIM
drop table seasondim1;
create table seasondim1 (
    season varchar2(20),
    startmonth NUMBER,
    endmonth NUMBER
);

insert into seasondim1 values ('Spring', 9, 11);
insert into seasondim1 values ('Summer', 12, 02);
insert into seasondim1 values ('Autumn', 03, 05);
insert into seasondim1 values ('Winter', 06, 08);
select * from seasondim1;

--Month Year DIM
DROP TABLE MONTHYEARDIM1;
CREATE TABLE MONTHYEARDIM1 AS 
    SELECT 
        DISTINCT(to_char(sale_date, 'MMYYYY')) as MonthYear     
    FROM sale;
    
INSERT INTO MONTHYEARDIM1
    SELECT distinct(to_char(movie_release_date, 'MMYYYY')) as monthyear 
    from movie;

ALTER TABLE MONTHYEARDIM1 ADD (
    MONTH VARCHAR(2),
    YEAR VARCHAR(4)
);
UPDATE MONTHYEARDIM1 SET MONTH = TO_CHAR(TO_DATE(MONTHYEAR, 'MMYYYY'), 'MM');
UPDATE MONTHYEARDIM1 SET YEAR  = TO_CHAR(TO_DATE(MONTHYEAR, 'MMYYYY'), 'YYYY');

SELECT * FROM MONTHYEARDIM1;

--Age Group DIM 
drop table agegroupdim1;
create table agegroupdim1 (
    agegroup varchar2(20),
    lower number,
    upper number
);

insert into agegroupdim1 values ('Child', null, 16);
insert into agegroupdim1 values ('Young Adults', 17, 30);
insert into agegroupdim1 values ('Middle-aged adults', 31, 45);
insert into agegroupdim1 values ('Old-ages adults', 45, null);
select * from agegroupdim1;

--Genre DIM
drop table GENREDIM1;
create table genredim1 as select genre_id as genreid, genre_description as genre from genre group by genre_id, genre_description;
select * from genredim1;

--Production Company DIM
drop table productioncompanyDIM1;
create table productioncompanyDIM1 as select company_id as companyid, company_name as company from production_company group by company_id, company_name;
select * from productioncompanyDIM1;

--Movie Runtime Category DIM
drop table movieruntimecategoryDIM1;
create table movieruntimecategoryDIM1(
    runtimecategory varchar(20),
    lower number,
    upper number
);

insert into movieruntimecategorydim1 values ('Short', null, 49);
insert into movieruntimecategorydim1 values ('Medium', 50, 100);
insert into movieruntimecategorydim1 values ('Long', 101, null);
select * from movieruntimecategorydim1;

--Booking Mode DIM
drop table bookingmodeDIM1;
create table bookingmodeDIM1 as select mode_description as bookingmode from booking_mode;
select * from bookingmodeDIM1;

--Cinema Location DIM
drop table cinemalocationDIM1;
create table cinemalocationDIM1 as 
select cinema_state || cinema_suburb as location, cinema_state AS STATE, cinema_suburb AS SUBURB from cinema group by cinema_state, cinema_suburb;
select * from cinemalocationDIM1;

--Cinema Rating DIM
drop table cinemaratingDIM1;
create table cinemaratingDIM1 as select distinct(rating_score) as rating from cinema_rating;
insert into cinemaratingdim1 values(0);

alter table cinemaratingdim1 add DESCRIPTION VARCHAR2(10);
UPDATE CINEMARATINGDIM1 SET 
DESCRIPTION = CASE RATING
                WHEN 1 THEN 'Poor'
                WHEN 2 THEN 'Not Good'
                WHEN 3 THEN 'Average'
                WHEN 4 THEN 'Good'
                WHEN 5 THEN 'Excellent'
                WHEN 0 THEN 'Unknown'
                END;

select * from cinemaratingdim1;

--Movie Review DIM
drop table moviereviewDIM1;
create table moviereviewDIM1 as select distinct(review_score) as moviereview from review;
insert into moviereviewdim1 values(0);

alter table moviereviewdim1 add DESCRIPTION VARCHAR2(10);
UPDATE moviereviewdim1 SET 
DESCRIPTION = CASE moviereview
                WHEN 1 THEN 'Poor'
                WHEN 2 THEN 'Not Good'
                WHEN 3 THEN 'Average'
                WHEN 4 THEN 'Good'
                WHEN 5 THEN 'Excellent'
                WHEN 0 THEN 'Unknown'
                END;
select * from moviereviewdim1;
--MovieDIM
drop table tempgenremoviedim1;
create table tempgenremoviedim1 as
select 
    m.movie_id as movieid, 
    movie_name as moviename, 
    round(1.0/count(g.genre_id),2) as genreweightfactor,
    listagg (g.genre_id, '_') within group (order by g.genre_id) as GenreGroupList
from movie m, movie_genre g
where m.movie_id = g.movie_id
group by m.movie_id, movie_name;
select * from tempgenremoviedim1;

drop table tempcompanymoviedim1;
create table tempcompanymovieDIM1 as 
select 
    m.movie_id as movieid, 
    movie_name as moviename, 
    round(1.0/count(c.company_id),2) as companyweightfactor,
    listagg (c.company_id, '_') within group (order by c.company_id) as CompanyGroupList
from movie m, movie_company c, movie_genre g
where m.movie_id = c.movie_id and m.movie_id = g.movie_id
group by m.movie_id, movie_name;

drop table movieDIM1;
create table moviedim1 as
select c.movieid as movieid, c.moviename as moviename, companyweightfactor, companygrouplist, genreweightfactor, genregrouplist
from tempcompanymoviedim1 c, tempgenremoviedim1 g
where c.movieid = g.movieid;

select * from moviedim1;

--MovieCompanyBridge
drop table moviecompanybridgetable1;
create table moviecompanybridgetable1 as select movie_id as movieid, company_id as companyid from movie_company;

select * from moviecompanybridgetable1;

--MovieGenreBridgeTable
DROP TABLE MOVIEGENREBRIDGETABLE1;
CREATE TABLE MOVIEGENREBRIDGETABLE1 AS SELECT MOVIE_ID AS MOVIEID, GENRE_ID AS GENREID FROM MOVIE_GENRE;

SELECT * FROM MOVIEGENREBRIDGETABLE1;

drop table tempmoviereview1;
create table tempmoviereview1 as
(select m.movie_id, m.movie_runtime, nvl(r.review_score, 0) as review
from movie m, review r
where m.movie_id = r.movie_id (+));

drop table tempmovieavgreview1;
create table tempmovieavgreview1 as 
(select movie_id, movie_runtime, round(avg(review)) as review
from tempmoviereview1
group by movie_id, movie_runtime);


drop table tempcinemarating1;
create table tempcinemarating1 as
(select c.cinema_id, c.cinema_state || c.cinema_suburb as location, nvl(r.rating_score, 0) as rating
from cinema c, cinema_rating r
where c.cinema_id = r.cinema_id (+));

drop table tempcinemaavgrating1;
create table tempcinemaavgrating1 as 
(select cinema_id, location, round(avg(rating)) as rating
from tempcinemarating1
group by cinema_id, location); 

select * from tempcinemaavgrating1;

--Sales FACT
drop table temp_salesfact1;
create table temp_salesfact1 as
select 
    to_char(s.sale_date, 'MMYYYY') as monthyear,
    cust.cust_dob as custdob,
    cr.rating as rating,
    c.cinema_state || c.cinema_suburb as location,
    bm.mode_description as bookingmode,
    m.movie_runtime as movieruntime,
    m.movie_id as movieid,
    r.review as moviereview,
    s.sale_total_price,
    s.sale_number_of_tickets
from sale s, booking_mode bm, movie m, tempmovieavgreview1 r, customer cust, cinema c, tempcinemaavgrating1 cr
where 
    s.movie_id = m.movie_id
and s.movie_id = r.movie_id
and s.mode_id = bm.mode_id
and s.cinema_id = c.cinema_id
and c.cinema_id = cr.cinema_id
and cust.cust_id = s.cust_id;

select * from temp_salesfact1;


alter table temp_salesfact1 add season varchar2(20);
update temp_salesfact1
set season = (
    CASE
    WHEN TO_NUMBER(TO_CHAR(TO_DATE(MONTHYEAR, 'MMYYYY'), 'MM')) BETWEEN 9 AND 11 THEN 'Spring'
    WHEN TO_NUMBER(TO_CHAR(TO_DATE(MONTHYEAR, 'MMYYYY'), 'MM')) BETWEEN 3 AND 5 THEN 'Autumn'
    WHEN TO_NUMBER(TO_CHAR(TO_DATE(MONTHYEAR, 'MMYYYY'), 'MM')) BETWEEN 6 AND 8 THEN 'Winter'
    ELSE 'Summer'
    END
);

select distinct(season) from temp_salesfact1;

alter table temp_salesfact1 add agegroup varchar2(20);
update temp_salesfact1
set agegroup = (
    CASE 
    WHEN floor((current_date - custdob)/365) <= 16 THEN 'Child'
    WHEN floor((current_date - custdob)/365) BETWEEN 17 AND 30 THEN 'Young Adults'
    WHEN floor((current_date - custdob)/365) BETWEEN 31 AND 45 THEN 'Middle-aged Adults'
    WHEN floor((current_date - custdob)/365) > 45 THEN 'Old-aged Adults'    
    ELSE null
    END
);
select distinct(agegroup) from temp_salesfact1;
select * from temp_salesfact1 where agegroup is NULL;

alter table temp_salesfact1 add runtimecategory varchar2(20);
update temp_salesfact1
set runtimecategory = (
    CASE
    WHEN MOVIERUNTIME < 50 THEN 'Short'
    WHEN MOVIERUNTIME BETWEEN 50 AND 100 THEN 'Medium'
    WHEN MOVIERUNTIME > 100 THEN 'Long'
    ELSE NULL
    END
);
select distinct(runtimecategory) from temp_salesfact1;
SELECT * FROM TEMP_SALESFACT1;

DROP TABLE SALESFACT1;
create table SALESFACT1 as 
    select 
        monthyear,
        SEASON,
        BOOKINGMODE,
        AGEGROUP,
        RATING,
        LOCATION,
        movieid,
        RUNTIMECATEGORY,
        MOVIEREVIEW,
        SUM(sale_number_of_tickets) as Number_Of_Tickets_Sold,
        SUM(sale_total_price) as Total_Revenue
    FROM TEMP_SALESFACT1
    GROUP BY
        monthyear,
        SEASON,
        BOOKINGMODE,
        AGEGROUP,
        RATING,
        LOCATION,
        movieid,
        RUNTIMECATEGORY,
        MOVIEREVIEW;

select * from salesfact1;

--Movie Fact
drop table temp_moviefact1;
create table temp_moviefact1 as
select to_char(s.sale_date, 'MMYYYY') as monthyear, 
       m.movie_runtime as movieruntime,
       r.review_score as moviereview,
       m.movie_id
from movie m, sale s, review r
where m.movie_id = s.movie_id
and   r.movie_id = m.movie_id;

select * from temp_moviefact1;

alter table temp_moviefact1 add season varchar2(20);
update temp_moviefact1
set season = (
    CASE
    WHEN TO_NUMBER(TO_CHAR(TO_DATE(MONTHYEAR, 'MMYYYY'), 'MM')) BETWEEN 9 AND 11 THEN 'Spring'
    WHEN TO_NUMBER(TO_CHAR(TO_DATE(MONTHYEAR, 'MMYYYY'), 'MM')) BETWEEN 3 AND 5 THEN 'Autumn'
    WHEN TO_NUMBER(TO_CHAR(TO_DATE(MONTHYEAR, 'MMYYYY'), 'MM')) BETWEEN 6 AND 8 THEN 'Winter'
    ELSE 'SUMMER'
    END
);

alter table temp_moviefact1 add runtimecategory varchar2(20);
update temp_moviefact1
set runtimecategory = (
    CASE
    WHEN movieruntime < 50 THEN 'Short'
    WHEN movieruntime BETWEEN 50 AND 100 THEN 'Medium'
    WHEN movieruntime > 100 THEN 'Long'
    ELSE NULL
    END
);
select distinct(runtimecategory) from temp_moviefact1;

drop table moviefact1;
create table moviefact1 as 
        select
            monthyear,
            season,
            runtimecategory,
            moviereview,
            count(movie_id) as Number_of_Movies
        from temp_moviefact1
        group by monthyear,season,runtimecategory,moviereview
        order by monthyear;

select * from moviefact1;

--CinemaFACT
drop table cinemafact1;
create table cinemafact1 as
select rating, location, count(*) as number_of_cinemas
from tempcinemaavgrating1
group by rating, location;


-- How many tickets were sold in October 2018? 73
SELECT SUM(NUMBER_OF_TICKETS_SOLD) AS TOTAL_TICKETS_SOLD
FROM SALESFACT1 S, MONTHYEARDIM1 M
WHERE M.MONTHYEAR = S.MONTHYEAR AND YEAR = 2018 AND MONTH = 10;

SELECT sum(sale_number_of_tickets)
from sale
where to_char(SALE_DATE, 'MM') = '10' AND to_char(SALE_DATE, 'YYYY') = '2018';

-- Which season has the highest sales revenue? Autumn -> 13420
SELECT SEASON, SALES_REVENUE FROM
(SELECT SEASON, SUM(TOTAL_REVENUE) AS SALES_REVENUE FROM SALESFACT1 GROUP BY SEASON ORDER BY SUM(TOTAL_REVENUE) DESC)
WHERE ROWNUM = 1;

-- How many short movies were released in 1990? 0
SELECT NVL(SUM(NUMBER_OF_MOVIES), 0) as Number_of_movies
FROM MOVIEFACT1 M, MONTHYEARDIM1 MY
WHERE M.MONTHYEAR = MY.MONTHYEAR AND YEAR = 1990 AND RUNTIMECATEGORY = 'Short';

SELECT * FROM MOVIE WHERE TO_CHAR(MOVIE_RELEASE_DATE, 'YYYY') = '1990' AND MOVIE_RUNTIME < 50;

-- How many 5 stars rating cinemas are there in Melbourne? 0
SELECT NVL(SUM(NUMBER_OF_CINEMAS), 0) as NUMBER_OF_CINEMAS 
FROM CINEMAFACT1 C, CINEMALOCATIONDIM1 L
WHERE 
    C.LOCATION = L.LOCATION
AND SUBURB = 'Melbourne' and rating = 5;

-- What is the most popular booking mode by young adults (by the number of sales)? In-Person -> 1030
SELECT BOOKINGMODE, TICKETS_SOLD FROM
(SELECT BOOKINGMODE, SUM(Number_Of_Tickets_Sold) AS TICKETS_SOLD FROM SALESFACT1 WHERE AGEGROUP = 'Young Adults' GROUP BY BOOKINGMODE ORDER BY 2 DESC)
WHERE ROWNUM = 1;

-- How much revenue was generated by short comedy movies in Winter 2020? 0
SELECT NVL(SUM(TOTAL_REVENUE) , 0) as total_revenue
FROM SALESFACT1 S, MONTHYEARDIM1 MY, MOVIEDIM1 M, MOVIEGENREBRIDGETABLE1 MG, GENREDIM1 G
WHERE 
    S.MONTHYEAR = MY.MONTHYEAR 
AND S.MOVIEID = M.MOVIEID
AND M.MOVIEID = MG.MOVIEID
AND MG.GENREID = G.GENREID
AND RUNTIMECATEGORY = 'Short' 
AND GENRE = 'Comedy' 
AND SEASON = 'Winter' 
AND YEAR = 2020;

SELECT * FROM SALE S, MOVIE M, MOVIE_GENRE MG, GENRE G
WHERE 
    S.MOVIE_ID = M.MOVIE_ID AND 
    M.MOVIE_ID = MG.MOVIE_ID AND
    G.GENRE_ID = MG.GENRE_ID AND
    MOVIE_RUNTIME < 50 AND
    GENRE_DESCRIPTION = 'Comedy' AND
    TO_CHAR(SALE_DATE, 'YYYY') = '2020' AND
    (TO_CHAR(SALE_DATE, 'MM') = '06' OR TO_CHAR(SALE_DATE, 'MM') = '07' OR TO_CHAR(SALE_DATE, 'MM') = '08');

-- What was the average sales revenue for 3 stars reviewed movies? 18.71
SELECT ROUND(AVG(TOTAL_REVENUE), 2) AS AVERAGE_SALES FROM SALESFACT1 WHERE MOVIEREVIEW = 3;

-- What were the total revenues for movies produced by NEW Century? 154
SELECT SUM(TOTAL_REVENUE) as total_revenue
FROM SALESFACT1 s, MOVIEDIM1 m, MOVIECOMPANYBRIDGETABLE1 mc, PRODUCTIONCOMPANYDIM1 c 
WHERE
    s.movieid = m.movieid
AND m.movieid = mc.movieid
AND mc.companyid = c.companyid
AND COMPANY = 'NEW Century';

SELECT SUM(SALE_TOTAL_PRICE)
FROM SALE S, PRODUCTION_COMPANY C, MOVIE_COMPANY MC
WHERE 
    S.MOVIE_ID = MC.MOVIE_ID
AND MC.COMPANY_ID = C.COMPANY_ID
AND COMPANY_NAME = 'NEW Century';

