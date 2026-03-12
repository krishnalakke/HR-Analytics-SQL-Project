create database veda
use veda
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    gender VARCHAR(10),
    dept_id INT,
    salary DECIMAL(10,2),
    hire_date DATE,
    performance_rating INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);



CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    attendance_date DATE,
    status VARCHAR(10),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

CREATE TABLE promotions (
    promotion_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    promotion_date DATE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);


INSERT INTO departments VALUES
(1, 'IT'),
(2, 'HR'),
(3, 'Finance'),
(4, 'Marketing');

INSERT INTO employees VALUES
(101, 'Ravi', 'Male', 1, 60000, '2022-03-15', 4),
(102, 'Sita', 'Female', 2, 55000, '2021-07-10', 5),
(103, 'Aman', 'Male', 1, 50000, '2023-01-05', 3),
(104, 'Neha', 'Female', 3, 65000, '2020-11-20', 4),
(105, 'Kiran', 'Male', 4, 48000, '2022-09-12', 2),
(106, 'Anjali', 'Female', 1, 70000, '2019-05-18', 5),
(107, 'Rahul', 'Male', 3, 52000, '2023-04-01', 3),
(108, 'Priya', 'Female', 2, 58000, '2021-12-25', 4);


INSERT INTO attendance (emp_id, attendance_date, status) VALUES
(101, '2025-03-01', 'Present'),
(101, '2025-03-02', 'Absent'),
(102, '2025-03-01', 'Present'),
(102, '2025-03-02', 'Present'),
(103, '2025-03-01', 'Absent'),
(103, '2025-03-02', 'Present'),
(104, '2025-03-01', 'Present'),
(104, '2025-03-02', 'Present'),
(105, '2025-03-01', 'Absent'),
(105, '2025-03-02', 'Absent'),
(106, '2025-03-01', 'Present'),
(106, '2025-03-02', 'Present'),
(107, '2025-03-01', 'Present'),
(107, '2025-03-02', 'Absent'),
(108, '2025-03-01', 'Present'),
(108, '2025-03-02', 'Present');


INSERT INTO promotions (emp_id, promotion_date) VALUES
(101, '2024-06-01'),
(102, '2023-08-15'),
(106, '2022-12-10'),
(108, '2024-01-20');


show tables 

select * from departments
select * from employees 
select * from attendance
--Q1) Total employees per department
select d.dept_name,count(e.emp_id) as total_employees 
from employees e 
left join departments d
on e.dept_id = d.dept_id
group by d.dept_name;

--Q2)Average salary per department

select d.dept_name,avg(e.salary) as avg_salary
from departments d
join employees e 
on d.dept_id = e. dept_id 
group by d.dept_name;

--Q3)Highest paid employee in each department

select d.dept_name , avg(e.salary) as avg_salary
from departments d 
join employees e
on d.dept_id = e.dept_id
group by d.dept_name
order by avg_salary desc
limit 1;

--Q4)Top 2 departments by average salary using RANK()

SELECT dept_name, avg_salary
FROM (
    SELECT d.dept_name,
           AVG(e.salary) AS avg_salary,
           RANK() OVER (ORDER BY AVG(e.salary) DESC) AS rnk
    FROM departments d
    JOIN employees e
    ON d.dept_id = e.dept_id
    GROUP BY d.dept_name
) ranked_departments
WHERE rnk <= 2;

--Q5)Top 2 employees within each department by salary
use veda
SELECT dept_name,
       emp_name,
       salary
FROM (
    SELECT d.dept_name,
           e.emp_name,
           e.salary,
           RANK() OVER (
               PARTITION BY d.dept_name
               ORDER BY e.salary DESC
           ) AS rnk
    FROM employees e
    JOIN departments d
    ON e.dept_id = d.dept_id
) ranked_employees
WHERE rnk <= 2;

--Q6)Employees earning above their department average salary--

SELECT e.emp_name,
       d.dept_name,
       e.salary
FROM employees e
JOIN departments d
ON e.dept_id = d.dept_id
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.dept_id = e.dept_id
);

USE VEDA
--Q7) Highest Paid Employee in Each Department.
select dept_name , emp_name , salary
from (
        SELECT d.dept_name , e.emp_name , e.salary,
        RANK() OVER (PARTITION BY d.dept_id ORDER BY e.salary DESC) AS rnk
from employees e
join departments d
on e.dept_id = d.dept_id
) ranked_employees
WHERE rnk = 1;

--Q8)who do not exist in the promotions table --
SELECT e.emp_name,
       d.dept_name
FROM employees e
LEFT JOIN promotions p
ON e.emp_id = p.emp_id
JOIN departments d
ON e.dept_id = d.dept_id
WHERE p.emp_id IS NULL;
use veda
select * from employees
select * from promotions


--Q9)Employees who got promoted more than once--

SELECT emp_name,
       performance_rating,
       CASE
           WHEN performance_rating >= 4 THEN 'Promoted'
           ELSE 'Not Promoted'
       END AS promotion_status
FROM employees;

--Q10)Employees Who Never Got Promotion (Using Rating)

SELECT emp_name,
       performance_rating
FROM employees
WHERE performance_rating  < 4;
use veda

--Q11)highest performance rating in each department?

SELECT dept_name,
       emp_name,
       performance_rating
FROM (
    SELECT d.dept_name,
           e.emp_name,
           e.performance_rating,
           RANK() OVER (
               PARTITION BY e.dept_id
               ORDER BY e.performance_rating DESC
           ) AS rnk
    FROM employees e
    JOIN departments d
    ON e.dept_id = d.dept_id
) ranked_employees
WHERE rnk = 1;

--Q12)identify employees who might leave the company?

SELECT e.emp_name,
       e.performance_rating,
       COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) AS absent_days
FROM employees e
JOIN attendance a
ON e.emp_id = a.emp_id
GROUP BY e.emp_id, e.emp_name, e.performance_rating
HAVING e.performance_rating <= 3
AND absent_days >= 1;


