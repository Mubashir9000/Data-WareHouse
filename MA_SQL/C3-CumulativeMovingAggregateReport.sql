--Report 8
--What are the total sales and cumulative total sales of animation movies in each year?
--DW 1
select year, 
    TO_CHAR (SUM(total_revenue), '9,999,999,999') AS total_sales,
    TO_CHAR (SUM(SUM(total_revenue)) OVER (ORDER BY year ROWS UNBOUNDED PRECEDING), '9,999,999,999') AS CUM_SALES
from salesfact1 s, monthyeardim1 m, moviedim1 mo, moviegenrebridgetable1 mg, genredim1 g
where s.monthyear = m.monthyear
and s.movieid = mo.movieid
and mo.movieid = mg.movieid
and mg.genreid = g.genreid
and lower(genre) like '%animation%'
group by year;

--DW 2
select to_char(saledate, 'YYYY') as year, 
    TO_CHAR (SUM(total_revenue), '9,999,999,999') AS total_sales,
    TO_CHAR (SUM(SUM(total_revenue)) OVER (ORDER BY to_char(saledate, 'YYYY') ROWS UNBOUNDED PRECEDING), '9,999,999,999') AS CUM_SALES
from salesfact2 s, salesdim2 m, moviedim2 mo, moviegenrebridgetable2 mg, genredim2 g
where s.saleid = m.saleid
and s.movieid = mo.movieid
and mo.movieid = mg.movieid
and mg.genreid = g.genreid
and lower(genre) like '%animation%'
group by to_char(saledate, 'YYYY');

--Report 9
-- Moving average sales for 4 star rating cinema for the current month and preceding two months
--DW1
select 
    year || '-' || month as calendar, 
    TO_CHAR (SUM(total_revenue), '9,999,999,999') AS revenue,
    TO_CHAR (AVG(SUM(total_revenue)) OVER
    (ORDER BY year || '-' || month ROWS 2 PRECEDING), '9,999,999,999') AS MOVING_3_MONTH_AVG
from salesfact1 f, monthyeardim1 m
where 
    f.monthyear = m.monthyear
and rating = 4
group by year || '-' || month;

--DW2
select 
    to_char(saledate, 'yyyy-mm') as calendar,
    TO_CHAR (SUM(total_revenue), '9,999,999,999') AS revenue,
    TO_CHAR (AVG(SUM(total_revenue)) OVER
    (ORDER BY to_char(saledate, 'yyyy-mm') ROWS 2 PRECEDING), '9,999,999,999') AS MOVING_3_MONTH_AVG
from salesfact2 f, salesdim2 s, cinemaratingdim2 cr
where 
    f.saleid = s.saleid
and f.cinemaratingid = cr.cinemaratingid
and rating = 4
group by to_char(saledate, 'yyyy-mm');

--REPORT 10
--Moving average tickets sold for 5 scored review movies for the current month and preceding two months
--Dw1
select
    year,month,
    TO_CHAR (SUM(number_of_tickets_sold),'9,999,999,999') AS TicketsSold,
    TO_CHAR (AVG(SUM(Number_Of_Tickets_Sold)) OVER (ORDER BY year, month ROWS 2 PRECEDING),'9,999,999,999') AS MOVING_3_MONTH_AVG
from salesfact1 f, monthyeardim1 m
where
    f.monthyear = m.monthyear
and moviereview = 5
group by year,month;
--Dw2
select
    to_char(saledate, 'yyyy') as year,to_char(saledate,'mm') as month,
    TO_CHAR (SUM(Number_Of_Tickets_Sold),'9,999,999,999') AS TicketsSold,
    TO_CHAR (AVG(SUM(Number_Of_Tickets_Sold)) OVER 
    (ORDER BY to_char(saledate, 'yyyy'),to_char(saledate,'mm') ROWS 2 PRECEDING),'9,999,999,999') AS MOVING_3_MONTH_AVG
from salesfact2 f, salesdim2 s, moviereviewdim2 mr
where
    f.saleid = s.saleid
and f.moviereviewid = mr.moviereviewid
and review = 5
group by to_char(saledate, 'yyyy'), to_char(saledate, 'mm');