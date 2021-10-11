--Report 4 (Cube)
--DW 1
select 
    decode(grouping(c.location), 1, 'All Locations', c.location) as location, 
    decode(grouping(se.season), 1, 'All Seasons', se.season) as season,
    decode(grouping(m.runtimecategory), 1, 'All Categories', m.runtimecategory) as runtimecategory,
    sum(s.total_revenue) as revenue
from salesfact1 s, cinemalocationdim1 c, seasondim1 se, movieruntimecategorydim1 m
where s.location = c.location
and s.season = se.season
and s.runtimecategory = m.runtimecategory
group by cube (c.location, se.season, m.runtimecategory);

--DW 2
select 
    decode(grouping((c.state || c.suburb)), 1, 'All Locations', (c.state || c.suburb)) as location, 
    decode(grouping(sa.season), 1, 'All Seasons', sa.season) as season, 
    decode(grouping(m.runtimecategory), 1, 'All Categories', m.runtimecategory) as runtimecategory, 
    sum(s.total_revenue) as revenue
from salesfact2 s, cinemadim2 c, salesdim2 sa, moviedim2 m
where s.cinemaid = c.cinemaid
and s.saleid = sa.saleid
and s.movieid = m.movieid
group by cube ((c.state || c.suburb), sa.season, m.runtimecategory);

--Report 5 (Partial Cube)
--DW 1
select 
    decode(grouping(c.location), 1, 'All Locations', c.location) as location, 
    decode(grouping(se.season), 1, 'All Seasons', se.season) as season,
    decode(grouping(m.runtimecategory), 1, 'All Categories', m.runtimecategory) as runtimecategory,
    sum(s.total_revenue) as revenue
from salesfact1 s, cinemalocationdim1 c, seasondim1 se, movieruntimecategorydim1 m
where s.location = c.location
and s.season = se.season
and s.runtimecategory = m.runtimecategory
group by c.location, cube (se.season, m.runtimecategory);

--DW 2
select 
    decode(grouping((c.state || c.suburb)), 1, 'All Locations', (c.state || c.suburb)) as location, 
    decode(grouping(sa.season), 1, 'All Seasons', sa.season) as season, 
    decode(grouping(m.runtimecategory), 1, 'All Categories', m.runtimecategory) as runtimecategory, 
    sum(s.total_revenue) as revenue
from salesfact2 s, cinemadim2 c, salesdim2 sa, moviedim2 m
where s.cinemaid = c.cinemaid
and s.saleid = sa.saleid
and s.movieid = m.movieid
group by (c.state || c.suburb), cube (sa.season, m.runtimecategory);

--Report 6
-- Subtotals of number of revenue for booking mode and location (suburb)
--DW1
SELECT
    DECODE(GROUPING(b.bookingmode), 1, 'All Booking Mode', b.bookingmode) as bookingmode,
    DECODE(GROUPING(suburb), 1, 'All Suburb', suburb) as suburb,
    sum(total_revenue) as revenue
FROM 
    salesfact1 f, bookingmodedim1 b, cinemalocationdim1 l
WHERE 
    f.bookingmode = b.bookingmode
AND f.location = l.location
GROUP BY ROLLUP(b.bookingmode, suburb);

--DW2
SELECT
    DECODE(GROUPING(b.bookingmode), 1, 'All Booking Mode', b.bookingmode) as bookingmode,
    DECODE(GROUPING(suburb), 1, 'All Suburb', suburb) as suburb,
    sum(total_revenue) as revenue
FROM 
    salesfact2 f, bookingmodedim2 b, cinemadim2 c
WHERE 
    f.bookingmode = b.bookingmode
AND f.cinemaid = c.cinemaid
GROUP BY ROLLUP(b.bookingmode, suburb);

--Report 7 (Partial Rollup)
--Subtotals of number of ticket sales for month and age group
--DW 1
select
    decode(grouping(m.month), 1, 'All Months', m.month) as month,
    decode(grouping(a.agegroup), 1, 'All Age Groups', a.agegroup) as agegroup,
    sum(s.number_of_tickets_sold) as number_of_tickets_sold
from salesfact1 s, monthyeardim1 m, agegroupdim1 a
where s.monthyear = m.monthyear
and s.agegroup = a.agegroup
group by m.month, rollup (a.agegroup);

--DW 2
select 
    decode(grouping(to_char(sa.saledate, 'MM')), 1, 'All Months', to_char(sa.saledate, 'MM')) as month,
    decode(grouping(c.agegroup), 1, 'All Age Groups', c.agegroup) as agegroup,
    sum(s.number_of_tickets_sold) as number_of_tickets_sold
from salesfact2 s, salesdim2 sa, custdim2 c
where s.saleid = sa.saleid
and s.custid = c.custid
group by to_char(sa.saledate, 'MM'), rollup (c.agegroup);

