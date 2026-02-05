select *
from employee_demographics as dem
join employee_salary as sal
on dem.employee_id = sal.employee_id;


SELECT first_name, last_name, 'Old man' as Label
from employee_demographics
where age > 40 AND gender = 'Male'
union
SELECT first_name, last_name, 'Old woman' as Label
from employee_demographics
where age > 40 AND gender = 'Female'
union
SELECT first_name, last_name, 'Highly Paid Employee' as Label
from employee_salary
where salary >70000
order by first_name, last_name;


-- String Functions
Select first_name, length(first_name)
from employee_demographics
order by length(first_name);

-- UPPER() LOWER() TRIM() TO GET RID OF WHITE SPACE LTRIM() RTRIM()
Select first_name,
LEFT(first_name,4),
RIGHT(first_name,4),
birth_date,
substring(birth_date,6,2) as birth_month -- very usefull
from employee_demographics;

SELECT first_name, REPLACE(first_name, 'a','z')
from employee_demographics;


SELECT first_name, LOCATE('an',first_name)
from employee_demographics;


SELECT first_name, last_name,
CONCAT(first_name,' ',last_name) as full_name -- super super usefull
from employee_demographics;


-- case statements
SELECT first_name, last_name,age,
CASE
	WHEN age <= 30 THEN 'young'
    WHEN age BETWEEN 30 and 50 THEN 'old'
    WHEN age >= 60 THEN "on death's door"
END AS age_bracket
from employee_demographics;


SELECT first_name, last_name, salary,
CASE
	WHEN salary < 50000 THEN salary * 1.05
    WHEN salary > 50000 THEN salary + (salary * 0.07)
END AS new_salary,
CASE
	WHEN dept_id = 6 THEN salary * .10
END as bouns
from employee_salary;

-- Subquery
SELECT *
from employee_demographics
where employee_id IN 
					(SELECT employee_id -- we can't use more than one column in subquery
					  FROM employee_salary
                      WHERE dept_id = 1);
                      
-- Since you are grouping by salary, every group has the same salary value, so:
-- 👉 AVG(salary) = salary
-- So this query is basically redundant.                      
SELECT first_name,salary, AVG(salary)
from employee_salary
group by first_name,salary;

-- The subquery calculates one single value:
-- the average salary of the whole table
-- That value is then shown for every row
SELECT first_name,salary,
						(SELECT AVG(salary)
						 from employee_salary)
from employee_salary;


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



-- Window Function 
SELECT gender, AVG(salary) as avg_salary
from employee_demographics dem 
JOIN employee_salary sal
on dem.employee_id = sal.employee_id
group by gender;
-- we can't use dem.first_name,dem.last_name with GROUP BY, everything will be different according to each group 

-- rolling total like gpa 
SELECT dem.first_name,dem.last_name,gender, salary,
SUM(salary) OVER(partition by gender order by dem.employee_id) rolling_total
from employee_demographics dem 
JOIN employee_salary sal
on dem.employee_id = sal.employee_id;


-- row number and rank 
SELECT dem.first_name,dem.last_name,gender, salary,
-- it gives a number for each row like an id if we use OVER()
ROW_NUMBER() OVER(partition by gender order by salary desc) AS row_num,
RANK() OVER(partition by gender order by salary desc) AS rank_num,
dense_rank() OVER(partition by gender order by salary desc) AS dense_rank_num
from employee_demographics dem 
JOIN employee_salary sal
on dem.employee_id = sal.employee_id