SELECT e.*, d.location FROM employees_partitioned e JOIN temp_departments d ON e.department = d.department_name;
