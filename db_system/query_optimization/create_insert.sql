CREATE TABLE Employees (
    emp_id int PRIMARY KEY,
    name varchar(100),
    department varchar(50),
    salary DECIMAL(10, 2)
);

INSERT INTO Employees (emp_id, name, department, salary)
SELECT
    i,
    'Employee_' || i,
    CASE (i % 5)
    WHEN 0 THEN
        'HR'
    WHEN 1 THEN
        'Engineering'
    WHEN 2 THEN
        'Sales'
    WHEN 3 THEN
        'Finance'
    ELSE
        'Marketing'
    END,
    ROUND((3000 + RANDOM() * 5000)::numeric, 2)
FROM
    generate_series(1, 1000) AS s (i);
