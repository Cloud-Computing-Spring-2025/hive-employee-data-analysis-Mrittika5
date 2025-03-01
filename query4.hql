SELECT job_role, COUNT(*) AS employee_count FROM employees_partitioned GROUP BY job_role;
