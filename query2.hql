SELECT department, AVG(salary) AS avg_salary FROM employees_partitioned GROUP BY department;
