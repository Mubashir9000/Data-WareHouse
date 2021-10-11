--Genre DIM
drop table GENREDIM2;
create table genredim2 as select genre_id as genreid, genre_description as genre from genre group by genre_id, genre_description;
select * from genredim;

--Production Company DIM
drop table productioncompanyDIM2;
create table productioncompanyDIM2 as select company_id as companyid, company_name as company from production_company group by company_id, company_name;
select * from productioncompanyDIM;

--Booking Mode DIM
drop table bookingmodeDIM2;
create table bookingmodeDIM2 as select mode_description as bookingmode from booking_mode;
select * from bookingmodeDIM2;

--Cinema Location DIM
drop table cinemaDIM2;
create table cinemaDIM2 as 
select cinema_id as cinemaid, cinema_suburb as suburb, cinema_state as state from cinema;

--MovieDIM
drop table tempgenremoviedim2;
create table tempgenremoviedim2 as
select 
    m.movie_id as movieid, 
    movie_name as moviename, 
    round(1.0/count(g.genre_id),2) as genreweightfactor,
    listagg (g.genre_id, '_') within group (order by g.genre_id) as GenreGroupList
from movie m, movie_genre g
where m.movie_id = g.movie_id
group by m.movie_id, movie_name;
select * from tempgenremoviedim2;

drop table tempcompanymoviedim2;
create table tempcompanymovieDIM2 as 
select 
    m.movie_id as movieid, 
    movie_name as moviename, 
    round(1.0/count(c.company_id),2) as companyweightfactor,
    listagg (c.company_id, '_') within group (order by c.company_id) as CompanyGroupList
from movie m, movie_company c, movie_genre g
where m.movie_id = c.movie_id and m.movie_id = g.movie_id
group by m.movie_id, movie_name;

drop table movieDIM2;
create table moviedim2 as
select 
    c.movieid as movieid, 
    c.moviename as moviename, 
    movie_release_date as releasedate,
    movie_runtime as runtime,
    companyweightfactor, 
    companygrouplist, 
    genreweightfactor, 
    genregrouplist
from movie m, tempcompanymoviedim2 c, tempgenremoviedim2 g
where c.movieid = g.movieid AND m.movie_id = c.movieid;

alter table moviedim2 add runtimecategory varchar2(20);
update moviedim2
set runtimecategory = (
    CASE
    WHEN RUNTIME < 50 THEN 'Short'
    WHEN RUNTIME BETWEEN 50 AND 100 THEN 'Medium'
    WHEN RUNTIME > 100 THEN 'Long'
    ELSE NULL
    END
);
select * from moviedim2;

--MovieCompanyBridge
drop table moviecompanybridgetable2;
create table moviecompanybridgetable2 as select movie_id as movieid, company_id as companyid from movie_company;

select * from moviecompanybridgetable2;

--MovieGenreBridgeTable
DROP TABLE MOVIEGENREBRIDGETABLE2;
CREATE TABLE MOVIEGENREBRIDGETABLE2 AS SELECT MOVIE_ID AS MOVIEID, GENRE_ID AS GENREID FROM MOVIE_GENRE;

SELECT * FROM MOVIEGENREBRIDGETABLE2;

--MovieReviewDIM
drop table tempmoviereview2;
create table tempmoviereview2 as
(select m.movie_id, nvl(r.review_score, 0) as review
from movie m, review r
where m.movie_id = r.movie_id (+));

drop table tempmovieavgreview2;
create table tempmovieavgreview2 as 
(select movie_id as movieid, round(avg(review)) as review
from tempmoviereview2
group by movie_id);

select * from tempmovieavgreview2;

drop table moviereviewDIM2;
create table moviereviewDIM2 as 
(select movieid || review as moviereviewid, review from tempmovieavgreview2);
select * from moviereviewdim2;

alter table moviereviewdim2 add DESCRIPTION VARCHAR2(10);
UPDATE moviereviewdim2 SET 
DESCRIPTION = CASE review
                WHEN 1 THEN 'Poor'
                WHEN 2 THEN 'Not Good'
                WHEN 3 THEN 'Average'
                WHEN 4 THEN 'Good'
                WHEN 5 THEN 'Excellent'
                WHEN 0 THEN 'Unknown'
                END;

--CinemaRatingDIM
drop table tempcinemarating2;
create table tempcinemarating2 as
(select c.cinema_id, nvl(r.rating_score, 0) as rating
from cinema c, cinema_rating r
where c.cinema_id = r.cinema_id (+));

drop table tempcinemaavgrating2;
create table tempcinemaavgrating2 as 
(select cinema_id, round(avg(rating)) as rating
from tempcinemarating2
group by cinema_id); 

select * from tempcinemaavgrating2;

drop table cinemaratingDIM2;
create table cinemaratingDIM2 as 
(select (cinema_id || rating) as cinemaratingid, rating from tempcinemaavgrating2);

alter table cinemaratingdim2 add DESCRIPTION VARCHAR2(10);
UPDATE CINEMARATINGDIM2 SET 
DESCRIPTION = CASE RATING
                WHEN 1 THEN 'Poor'
                WHEN 2 THEN 'Not Good'
                WHEN 3 THEN 'Average'
                WHEN 4 THEN 'Good'
                WHEN 5 THEN 'Excellent'
                WHEN 0 THEN 'Unknown'
                END;
select * from cinemaratingdim2;

--CUSTDIM
DROP TABLE CUSTDIM2;
CREATE TABLE CUSTDIM2 AS
(SELECT CUST_ID AS CUSTID, CUST_NAME AS NAME, CUST_DOB AS DOB FROM CUSTOMER);

ALTER TABLE CUSTDIM2 ADD AGEGROUP VARCHAR2(20);
update CUSTDIM2
set agegroup = (
    CASE 
    WHEN floor((current_date - dob)/365) <= 16 THEN 'Child'
    WHEN floor((current_date - dob)/365) BETWEEN 17 AND 30 THEN 'Young Adults'
    WHEN floor((current_date - dob)/365) BETWEEN 31 AND 45 THEN 'Middle-aged Adults'
    WHEN floor((current_date - dob)/365) > 45 THEN 'Old-aged Adults'    
    ELSE null
    END
);
SELECT * FROM CUSTDIM2;

DROP TABLE SALESDIM2;
CREATE TABLE SALESDIM2 AS
(SELECT SALE_ID AS SALEID, SALE_DATE AS SALEDATE FROM SALE);

ALTER TABLE SALESDIM2 ADD SEASON VARCHAR2(20);
update SALESDIM2
set season = (
    CASE
    WHEN TO_NUMBER(TO_CHAR(TO_DATE(SALEDATE, 'DD-MM-YYYY'), 'MM')) BETWEEN 9 AND 11 THEN 'Spring'
    WHEN TO_NUMBER(TO_CHAR(TO_DATE(SALEDATE, 'DD-MM-YYYY'), 'MM')) BETWEEN 3 AND 5 THEN 'Autumn'
    WHEN TO_NUMBER(TO_CHAR(TO_DATE(SALEDATE, 'DD-MM-YYYY'), 'MM')) BETWEEN 6 AND 8 THEN 'Winter'
    ELSE 'Summer'
    END
);
select * from salesdim2;

--Sales FACT
drop table tempsalesfact2;
create table tempsalesfact2 as
(select 
    s.sale_id as saleid,
    cust.cust_id as custid,
    cr.cinema_id || cr.rating as cinemaratingid,
    c.cinema_id as cinemaid,
    bm.mode_description as bookingmode,
    m.movie_id as movieid,
    mr.movieid || mr.review as moviereviewid,
    s.sale_total_price,
    s.sale_number_of_tickets
from sale s, booking_mode bm, movie m, tempmovieavgreview2 mr, customer cust, cinema c, tempcinemaavgrating2 cr
where 
    s.movie_id = m.movie_id
and s.movie_id = mr.movieid
and s.mode_id = bm.mode_id
and s.cinema_id = c.cinema_id
and c.cinema_id = cr.cinema_id
and cust.cust_id = s.cust_id);

select * from tempsalesfact2;

DROP TABLE SALESFACT2;
create table SALESFACT2 as 
    select 
        saleid,
        custid,
        BOOKINGMODE,
        CINEMARATINGID,
        CINEMAID,
        movieid,
        MOVIEREVIEWID,
        SUM(sale_number_of_tickets) as Number_Of_Tickets_Sold,
        SUM(sale_total_price) as Total_Revenue
    FROM TEMPSALESFACT2
    GROUP BY
        saleid,
        custid,
        BOOKINGMODE,
        CINEMARATINGID,
        CINEMAID,
        movieid,
        MOVIEREVIEWID;

select * from salesfact2;

--CinemaFACT
drop table cinemafact2;
create table cinemafact2 as
(
select cinema_id || rating as cinemaratingid, cinema_id as cinemaid, count(*) as number_of_cinemas
from tempcinemaavgrating2
group by cinema_id || rating, cinema_id
);
select * from cinemafact2;

--MovieFact
DROP TABLE MOVIEFACT2;
CREATE TABLE MOVIEFACT2 AS
(
    SELECT MOVIEID, MOVIEID || REVIEW AS MOVIEREVIEWID, COUNT(MOVIEID) AS NUMBER_OF_MOVIES
    FROM TEMPMOVIEAVGREVIEW2
    GROUP BY MOVIEID, MOVIEID || REVIEW
);

SELECT * FROM MOVIEFACT2;

-- How many tickets were sold in October 2018
SELECT SUM(NUMBER_OF_TICKETS_SOLD) AS TOTAL_TICKETS_SOLD
FROM SALESFACT2 F, SALESDIM2 S
WHERE 
    F.SALEID = S.SALEID
AND TO_CHAR(SALEDATE, 'MON-YY') = 'OCT-18';

SELECT sum(sale_number_of_tickets)
from sale
where to_char(SALE_DATE, 'MM') = '10' AND to_char(SALE_DATE, 'YYYY') = '2018';

-- Which season has the highest sales revenue?
SELECT SEASON, SALES_REVENUE FROM
(
SELECT SEASON, SUM(TOTAL_REVENUE) AS SALES_REVENUE 
FROM SALESFACT2 F, SALESDIM2 S
WHERE F.SALEID = S.SALEID
GROUP BY SEASON
ORDER BY SUM(TOTAL_REVENUE) DESC
)
WHERE ROWNUM = 1;

-- How many short movies were released in 1990?
SELECT NVL(SUM(NUMBER_OF_MOVIES), 0) as Number_of_movies
FROM MOVIEFACT2 F, MOVIEDIM2 M
WHERE 
    F.MOVIEID = M.MOVIEID
AND RUNTIMECATEGORY = 'Short'
AND TO_CHAR(RELEASEDATE, 'YY') = '90';

SELECT * FROM MOVIE WHERE TO_CHAR(MOVIE_RELEASE_DATE, 'YYYY') = '1990' AND MOVIE_RUNTIME < 50;

-- How many 5 stars rating cinemas are there in Melbourne?
SELECT NVL(SUM(NUMBER_OF_CINEMAS), 0) as NUMBER_OF_CINEMAS 
FROM CINEMAFACT2 F, CINEMADIM2 C, CINEMARATINGDIM2 CR
WHERE 
    F.CINEMAID = C.CINEMAID
AND F.CINEMARATINGID = CR.CINEMARATINGID
AND LOWER(SUBURB) = 'melbourne' and rating = 5;

-- What is the most popular booking mode by young adults (by the number of sales)?
SELECT BOOKINGMODE, TICKETS_SOLD FROM
(
    SELECT BOOKINGMODE, SUM(Number_Of_Tickets_Sold) AS TICKETS_SOLD 
    FROM SALESFACT2 F, CUSTDIM2 C
    WHERE 
        F.CUSTID = C.CUSTID
    AND AGEGROUP = 'Young Adults' 
    GROUP BY BOOKINGMODE ORDER BY 2 DESC
)
WHERE ROWNUM = 1;

-- How much revenue was generated by short comedy movies in Winter 2020?
SELECT NVL(SUM(TOTAL_REVENUE) , 0) as total_revenue
FROM SALESFACT2 F, SALESDIM2 S, MOVIEDIM2 M, MOVIEGENREBRIDGETABLE2 MG, GENREDIM2 G
WHERE 
    F.SALEID = S.SALEID
AND F.MOVIEID = M.MOVIEID
AND M.MOVIEID = MG.MOVIEID
AND MG.GENREID = G.GENREID
AND RUNTIMECATEGORY = 'Short' 
AND GENRE = 'Comedy' 
AND SEASON = 'Winter' 
AND TO_CHAR(SALEDATE, 'YY') = '20';

SELECT * FROM SALE S, MOVIE M, MOVIE_GENRE MG, GENRE G
WHERE 
    S.MOVIE_ID = M.MOVIE_ID AND 
    M.MOVIE_ID = MG.MOVIE_ID AND
    G.GENRE_ID = MG.GENRE_ID AND
    MOVIE_RUNTIME < 50 AND
    GENRE_DESCRIPTION = 'Comedy' AND
    TO_NUMBER(TO_CHAR(SALE_DATE, 'YY')) = 20 AND
    (TO_CHAR(SALE_DATE, 'MM') = '06' OR TO_CHAR(SALE_DATE, 'MM') = '07' OR TO_CHAR(SALE_DATE, 'MM') = '08');

-- What was the average sales revenue for 3 stars reviewed movies?
SELECT ROUND(AVG(TOTAL_REVENUE), 2) AS AVERAGE_SALES 
FROM SALESFACT2 F, MOVIEREVIEWDIM2 MR
WHERE
    F.MOVIEREVIEWID = MR.MOVIEREVIEWID
AND REVIEW = 3;

---- What were the total revenues for movies produced by NEW Century?
SELECT SUM(TOTAL_REVENUE) as total_revenue
FROM SALESFACT2 s, MOVIEDIM2 m, MOVIECOMPANYBRIDGETABLE2 mc, PRODUCTIONCOMPANYDIM2 c 
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

