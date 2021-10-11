--REPORT 1
-- TOP 10% Location (Suburb) and Age Group Ticket Sales
--DW1
SELECT * FROM(
    SELECT
        suburb,
        f.agegroup,
        sum(total_revenue) as revenue,
        percent_rank() over (order by sum(total_revenue) desc) as percentrank
    FROM
        salesfact1 f, cinemalocationdim1 l, agegroupdim1 a
    WHERE
        f.location = l.location
    AND f.agegroup = a.agegroup
    GROUP BY suburb, f.agegroup
) WHERE percentrank < 0.1;

--DW2
SELECT * FROM(
    SELECT
        suburb,
        agegroup,
        sum(total_revenue) as revenue,
        percent_rank() over (order by sum(total_revenue) desc) as percentrank
    FROM
        salesfact2 f, cinemadim2 c, custdim2 cust
    WHERE
        f.cinemaid = c.cinemaid
    AND f.custid = cust.custid
    GROUP BY suburb, agegroup
) WHERE percentrank < 0.1;

--REPORT 2
--Show all number of tickets sold by the movie runtime category from each age group
--DW 1
select a.agegroup, m.runtimecategory, sum(s.number_of_tickets_sold)
from salesfact1 s, agegroupdim1 a, movieruntimecategorydim1 m
where s.agegroup = a.agegroup
and s.runtimecategory = m.runtimecategory
group by a.agegroup, m.runtimecategory;

--DW 2
select c.agegroup, m.runtimecategory, sum(s.number_of_tickets_sold)
from custdim2 c, moviedim2 m, salesfact2 s
where c.custid = s.custid
and m.movieid = s.movieid
group by c.agegroup, m.runtimecategory;

-- REPORT 3
--Top 10 Location and Season Ticket Sales
--Dw1
SELECT * FROM(
    Select
        suburb,
        r.season,
        sum(total_revenue) as revenue,
        rank() over (order by sum(total_revenue) desc ) as rank
    from
        salesfact1 f, cinemalocationdim1 m,seasondim1 r
    where
        f.location=m.location and
        f.season=r.season
    group by suburb,r.season)
where rank < 10;
--Dw2
select * from(
    select 
        suburb,
        r.season,
        sum(total_revenue) as revenue,
        rank() over (order by sum(total_revenue) desc ) as rank
    from
        salesfact2 f, cinemadim2 m,salesdim2 r
    where
        f.cinemaid=m.cinemaid and
        f.saleid=r.saleid
    group by suburb,r.season)
where rank < 10;