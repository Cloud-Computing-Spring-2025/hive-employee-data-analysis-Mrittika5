SELECT * FROM (SELECT emp_id, name, department, salary, RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank FROM employees_partitioned) ranked WHERE rank <= 3;
