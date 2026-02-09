-- CTEs  common table expression
-- the two quieries below are the same but CTE is best practice
With CTE_EXAMPLE(Gender,AVG_AGE,MAX_AGE,MIN_AGE,COUNT_AGE) as 
(
SELECT gender,
    avg(age) as avg_age,
    max(age) as max_age,
    min(age) as min_age,
    count(age) as count_age
    from employee_demographics
    group by gender
)
SELECT *
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



With CTE_EXAMPLE as 
(
SELECT employee_id, gender, birth_date
FROM employee_demographics
WHERE birth_date > '1985-01-01'
),
CTE_EXAMPLE2 as 
(
SELECT employee_id, salary
FROM employee_salary
WHERE salary > 50000
)
SELECT *
from CTE_EXAMPLE
JOIN CTE_EXAMPLE2 
ON CTE_EXAMPLE.employee_id = CTE_EXAMPLE2.employee_id;


-- Temporary table
CREATE TEMPORARY TABLE salary_over_50k
SELECT *
FROM employee_salary
WHERE salary >= 50000;

SELECT * 
FROM salary_over_50k;


-- Stored procedures
DELIMITER $$
CREATE PROCEDURE employee_salary_procedure(p_employee_id INT)
BEGIN
	SELECT salary
    FROM employee_salary
    WHERE employee_id = p_employee_id;
END $$
DELIMITER ;

CALL employee_salary_procedure(2);

    
    
-- TRIGGERS 
DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW
BEGIN
	INSERT INTO employee_demographics(employee_id, first_name, last_name)
    VALUES ( NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
DELIMITER ; 

INSERT INTO employee_salary(employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (13, 'Islam', 'ALAbed', 'Entertainment 720 CEO', 80000, NULL);


SELECT * 
FROM employee_salary;

SELECT * 
FROM employee_demographics;

-- EVENTS 
DELIMITER $$
CREATE EVENT delete_retirees
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN
	DELETE 
    FROM employee_demographics
    WHERE age >= 60;
END $$
DELIMITER ; 

SHOW VARIABLES LIKE 'event%';