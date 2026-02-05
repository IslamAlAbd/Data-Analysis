-- CTEs 
-- the two quieries below are the same but CTE is best practice
With CTE_EXAMPLE as 
(
SELECT gender,
    avg(age) as avg_age,
    max(age) as max_age,
    min(age) as min_age,
    count(age) as count_age
    from employee_demographics
    group by gender
)
SELECT avg(max_age)
from CTE_EXAMPLE;


SELECT avg(max_age) 
from (
	SELECT gender,
    avg(age) as avg_age,
    max(age) as max_age,
    min(age) as min_age,
    count(age) as count_age
    from employee_demographics
    group by gender
) as agg_table;