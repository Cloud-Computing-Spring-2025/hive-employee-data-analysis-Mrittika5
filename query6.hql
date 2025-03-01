SELECT department, COUNT(*) AS emp_count FROM employees_partitioned GROUP BY department ORDER BY emp_count DESC LIMIT 1;
