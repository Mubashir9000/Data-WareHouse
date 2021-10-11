--REPORT 11
-- Ranking of each movie genre based on monthly total tickets sold 
-- and the Ranking of each booking mode based on monthly total tickets sold
-- DW1
-- Combined (Doesn't Make Sense)
SELECT 
    genre, b.bookingmode, year || '-' || month AS CALENDAR,
    TO_CHAR(SUM(number_of_tickets_sold)) AS TicketsSold,
    RANK() OVER (PARTITION BY year || '-' || month
        ORDER BY SUM(number_of_tickets_sold) DESC) AS RANK_BY_GENRE,
    RANK() OVER (PARTITION BY year || '-' || month
        ORDER BY SUM(number_of_tickets_sold) DESC) AS RANK_BY_BOOKINGMODE
FROM 
    salesfact1 f, moviedim1 m, moviegenrebridgetable1 mg, genredim1 g, bookingmodedim1 b, monthyeardim1 my
WHERE 

    f.monthyear = my.monthyear
AND f.movieid = m.movieid
AND m.movieid = mg.movieid
AND mg.genreid = g.genreid
AND f.bookingmode = b.bookingmode
GROUP BY genre, b.bookingmode, year || '-' || month;

-- Genre
SELECT 
    genre, year || '-' || month AS CALENDAR,
    TO_CHAR(SUM(number_of_tickets_sold)) AS TicketsSold,
    RANK() OVER (PARTITION BY year || '-' || month
        ORDER BY SUM(number_of_tickets_sold) DESC) AS RANK_BY_GENRE
FROM 
    salesfact1 f, moviedim1 m, moviegenrebridgetable1 mg, genredim1 g, monthyeardim1 my
WHERE 
    f.movieid = m.movieid
AND m.movieid = mg.movieid
AND mg.genreid = g.genreid
AND f.monthyear = my.monthyear
GROUP BY genre, year || '-' || month;

-- BookingMode
SELECT 
    b.bookingmode, year || '-' || month as calendar,
    TO_CHAR(SUM(number_of_tickets_sold)) AS TicketsSold,
    RANK() OVER (PARTITION BY year || '-' || month
        ORDER BY SUM(number_of_tickets_sold) DESC) AS RANK_BY_BOOKINGMODE
FROM 
    salesfact1 f, monthyeardim1 my, bookingmodedim1 b
WHERE
    f.monthyear = my.monthyear
AND f.bookingmode = b.bookingmode
GROUP BY b.bookingmode, year || '-' || month;

-- DW2
-- Combined (Doesn't Make Sense)
SELECT 
    genre, b.bookingmode, TO_CHAR(SALEDATE, 'YYYY-MM') AS CALENDAR,
    TO_CHAR(SUM(number_of_tickets_sold)) AS TicketsSold,
    RANK() OVER (PARTITION BY TO_CHAR(SALEDATE, 'YYYY-MM')
        ORDER BY SUM(number_of_tickets_sold) DESC) AS RANK_BY_GENRE,
    RANK() OVER (PARTITION BY TO_CHAR(SALEDATE, 'YYYY-MM')
        ORDER BY SUM(number_of_tickets_sold) DESC) AS RANK_BY_BOOKINGMODE
FROM 
    salesfact2 f, salesdim2 s, moviedim2 m, moviegenrebridgetable2 mg, genredim2 g, bookingmodedim2 b
WHERE 
    
    f.saleid = s.saleid
AND f.movieid = m.movieid
AND m.movieid = mg.movieid
AND mg.genreid = g.genreid
AND f.bookingmode = b.bookingmode
GROUP BY genre, b.bookingmode, TO_CHAR(SALEDATE, 'YYYY-MM');

-- Genre
SELECT 
    genre, TO_CHAR(SALEDATE, 'YYYY-MM') AS CALENDAR,
    TO_CHAR(SUM(number_of_tickets_sold)) AS TicketsSold,
    RANK() OVER (PARTITION BY TO_CHAR(SALEDATE, 'YYYY-MM')
        ORDER BY SUM(number_of_tickets_sold) DESC) AS RANK_BY_GENRE
FROM 
    salesfact2 f, moviedim2 m, moviegenrebridgetable2 mg, genredim2 g, salesdim2 s
WHERE 
    f.movieid = m.movieid
AND m.movieid = mg.movieid
AND mg.genreid = g.genreid
AND f.saleid = s.saleid
GROUP BY genre, TO_CHAR(SALEDATE, 'YYYY-MM');

-- BookingMode
SELECT 
    b.bookingmode, TO_CHAR(SALEDATE, 'YYYY-MM') AS CALENDAR,
    TO_CHAR(SUM(number_of_tickets_sold)) AS TicketsSold,
    RANK() OVER (PARTITION BY TO_CHAR(SALEDATE, 'YYYY-MM')
        ORDER BY SUM(number_of_tickets_sold) DESC) AS RANK_BY_BOOKINGMODE
FROM 
    salesfact2 f, salesdim2 s, bookingmodedim2 b
WHERE
    f.saleid = s.saleid
AND f.bookingmode = b.bookingmode
GROUP BY b.bookingmode, TO_CHAR(SALEDATE, 'YYYY-MM');

--REPORT 12
--Ranking of each production company based on monthly revenue 
--DW1
select
    company,year||'-'||month as calendar,
    to_char(SUM(total_revenue)) AS Revenue,
    RANK() OVER (PARTITION BY year ||'-'||month 
        ORDER BY SUM(total_revenue)DESC) AS RANK_BY_COMPANY
FROM 
    salesfact1 f, monthyeardim1 my,moviedim1 m,moviecompanybridgetable1 mc, productioncompanydim1 c
WHERE
    f.movieid=m.movieid
AND m.movieid=mc.movieid
AND mc.companyid=c.companyid
AND f.monthyear=my.monthyear
GROUP BY company,year||'-'||month;

--DW2
SELECT 
    company, TO_CHAR(SALEDATE, 'YYYY-MM') AS CALENDAR,
    TO_CHAR(SUM(total_revenue)) AS Revenue,
    RANK() OVER (PARTITION BY TO_CHAR(SALEDATE, 'YYYY-MM')
        ORDER BY SUM(total_revenue) DESC) AS RANK_BY_COMPANY
FROM 
    salesfact2 f, moviedim2 m, moviecompanybridgetable2 mc, productioncompanydim2 c, salesdim2 s
WHERE 
    f.movieid = m.movieid
AND m.movieid = mc.movieid
AND mc.companyid = c.companyid
AND f.saleid = s.saleid
GROUP BY company, TO_CHAR(SALEDATE, 'YYYY-MM');