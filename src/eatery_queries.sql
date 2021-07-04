-- 1. What is the average permit duration? Which eatery has the longest permit?

create or replace function duration_calc(start_date date, end_date date)
returns numeric as
    'select (end_date - start_date)::decimal;'
language sql;


select avg(abs(duration_calc(end_date, start_date))) as average_permit_duration
from eatery ;


select distinct name, abs(duration_calc(start_date, end_date)) as duration
from eatery
where (abs(duration_calc(start_date, end_date))) =
      (select max(abs(duration_calc(start_date, end_date))) from eatery);



-- +-----------------------+
-- |average_permit_duration|
-- +-----------------------+
-- |2092.6595744680851064  |
-- +-----------------------+

-- +-----------------------------+--------+
-- |name                         |duration|
-- +-----------------------------+--------+
-- |The Vanderbilt at South Beach|8969    |
-- +-----------------------------+--------+




-- 2. What is the count of eateries per year based on permit start date?

select extract(YEAR from start_date) as year, count(name) as number_of_eateries
from eatery
where extract(YEAR from start_date) IS NOT NULL
group by year;


-- +----+------------------+
-- |year|number_of_eateries|
-- +----+------------------+
-- |2007|2                 |
-- |2005|2                 |
-- |2011|3                 |
-- |2014|9                 |
-- |2010|4                 |
-- |2019|63                |
-- |2018|46                |
-- |2013|3                 |
-- |2004|1                 |
-- |2000|1                 |
-- +----+------------------+



-- 3. What are the names and eatery types of every eatery in the dataset?

CREATE table eatery_type(eatery_type_id serial primary key, type_name text);

INSERT INTO eatery_type(type_name)
SELECT DISTINCT type_name FROM eatery;

ALTER TABLE eatery
    ADD COLUMN eatery_type_id INTEGER
    REFERENCES eatery_type (eatery_type_id);

UPDATE eatery as e
SET eatery_type_id = et.eatery_type_id
FROM eatery_type as et
WHERE e.type_name = et.type_name;


ALTER TABLE eatery DROP COLUMN type_name;


select distinct name, type_name
from eatery_type e
INNER JOIN eatery e2 on e.eatery_type_id = e2.eatery_type_id;


-- +-------------------------------------------------+-----------------+
-- |name                                             |type_name        |
-- +-------------------------------------------------+-----------------+
-- |Pushcart                                         |Food Cart        |
-- |Maurice A Fitzgerald Playground Mobile Food Truck|Mobile Food Truck|
-- |Vinmont Veteran Park Mobile Food Truck           |Mobile Food Truck|
-- |Van Cortlandt Park Mobile Food Truck             |Food Cart        |
-- |Bayview Playground Mobile Trucks                 |Mobile Food Truck|
-- |Woodlawn Memorial Mobile Food Truck              |Mobile Food Truck|
-- |Memorial Field Mobile Food Truck                 |Mobile Food Truck|
-- |The Stone House                                  |Restaurant       |
-- |Coney Island Food Cart                           |Food Cart        |
-- |Travers Park Food Cart                           |Food Cart        |
-- +-------------------------------------------------+-----------------+


-- 4. Which eateries are a cart, and which eateries aren't a cart?

select eatery_id, name, permit_number, CASE
    WHEN lower(type_name) LIKE '%cart%' THEN 'Cart'
    ELSE type_name
END AS type
FROM eatery e
INNER JOIN eatery_type et on e.eatery_type_id = et.eatery_type_id;


-- +---------+----------------------+-------------+---------+
-- |eatery_id|name                  |permit_number|type     |
-- +---------+----------------------+-------------+---------+
-- |51       |Sunset Park Food Cart |B87-C        |Cart     |
-- |203      |Olmsted Cafeteria     |Q99-J-SB     |Snack Bar|
-- |1        |Central Park Food Cart|M10-72-1A-C  |Cart     |
-- |2        |Central Park Food Cart|M10-72-3-C   |Cart     |
-- |3        |Central Park Food Cart|M10-72-ED-C  |Cart     |
-- |4        |Central Park Food Cart|M10-74-WD-C  |Cart     |
-- |5        |Central Park Food Cart|M10-81-WD-C  |Cart     |
-- |6        |Central Park Food Cart|M10-84-ED-C  |Cart     |
-- |7        |Central Park Food Cart|M10-W65-C    |Cart     |
-- |8        |Central Park Food Cart|M10-W67-C    |Cart     |
-- +---------+----------------------+-------------+---------+


-- 5. Can this be easier / how many are carts, and how many are every other type?

create or replace view eatery_report as
select eatery_id, name, permit_number, CASE
    WHEN lower(type_name) LIKE '%cart%' THEN 'Cart'
    ELSE type_name
END AS type
FROM eatery e
INNER JOIN eatery_type et on e.eatery_type_id = et.eatery_type_id;

select type, count(type)
from eatery_report
group by type;

-- +-----------------+-----+
-- |type             |count|
-- +-----------------+-----+
-- |Restaurant       |14   |
-- |Cart             |98   |
-- |Snack Bar        |28   |
-- |Mobile Food Truck|97   |
-- +-----------------+-----+

-- 6. How many eateries are there per borough?

create or replace view borough_report as
select eatery_id, name, park_id, CASE
    WHEN park_id LIKE 'X%' THEN 'Bronx'
    WHEN park_id LIKE 'B%' THEN 'Brooklyn'
    WHEN park_id LIKE 'M%' THEN 'Manhattan'
    WHEN park_id LIKE 'Q%' THEN 'Queens'
    WHEN park_id LIKE 'R%' THEN 'Staten Island'
END AS borough
FROM eatery e;

select borough, count(borough)
from borough_report
group by borough;

-- +-------------+-----+
-- |borough      |count|
-- +-------------+-----+
-- |Brooklyn     |32   |
-- |Bronx        |48   |
-- |Manhattan    |90   |
-- |Queens       |51   |
-- |Staten Island|16   |
-- +-------------+-----+


-- 7. Can this be faster?

EXPLAIN ANALYZE select name from eatery where name = 'Pushcart';

-- +------------------------------------------------------------------------------------------------+
-- |QUERY PLAN                                                                                      |
-- +------------------------------------------------------------------------------------------------+
-- |Seq Scan on eatery  (cost=0.00..15.96 rows=1 width=29) (actual time=0.016..0.068 rows=1 loops=1)|
-- |  Filter: (name = 'Pushcart'::text)                                                             |
-- |  Rows Removed by Filter: 236                                                                   |
-- |Planning Time: 0.157 ms                                                                         |
-- |Execution Time: 0.080 ms                                                                        |
-- +------------------------------------------------------------------------------------------------+


CREATE INDEX name_index ON eatery (name);



EXPLAIN ANALYZE select name from eatery where name = 'Pushcart';

-- +-----------------------------------------------------------------------------------------------------------------------+
-- |QUERY PLAN                                                                                                             |
-- +-----------------------------------------------------------------------------------------------------------------------+
-- |Index Only Scan using name_index on eatery  (cost=0.27..4.29 rows=1 width=29) (actual time=0.019..0.020 rows=1 loops=1)|
-- |  Index Cond: (name = 'Pushcart'::text)                                                                                |
-- |  Heap Fetches: 0                                                                                                      |
-- |Planning Time: 0.091 ms                                                                                                |
-- |Execution Time: 0.031 ms                                                                                               |
-- +-----------------------------------------------------------------------------------------------------------------------+



EXPLAIN ANALYZE select name from eatery where name like '%Push';
-- +------------------------------------------------------------------------------------------------+
-- |QUERY PLAN                                                                                      |
-- +------------------------------------------------------------------------------------------------+
-- |Seq Scan on eatery  (cost=0.00..15.96 rows=1 width=29) (actual time=0.055..0.056 rows=0 loops=1)|
-- |  Filter: (name ~~ '%Push'::text)                                                               |
-- |  Rows Removed by Filter: 237                                                                   |
-- |Planning Time: 0.147 ms                                                                         |
-- |Execution Time: 0.064 ms                                                                        |
-- +------------------------------------------------------------------------------------------------+
