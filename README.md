# Employee & Department Analysis with Hive

## **Setup & Running Docker Compose**

1. **Start Docker and Run Hive Environment**
   ```sh
   docker-compose up -d
   ```
   This will start all necessary services, including Hive, HDFS, and Hue.

2. **Access Hue Web Interface**
   - Open a browser and go to `http://localhost:8888`
 
---

## **Uploading CSV Files to Hue**

1. **Go to Hue File Browser**
   - Click **File Browser** in the Hue sidebar.
   - Navigate to `/user/hive/warehouse/`.

2. **Upload Files**
   - Click **Upload** → **Choose File** → Select `employees.csv`.
   - Click **Upload**.
  


  


## **Creating Temporary Tables in Hive**

### **1. Open Hue Query Editor**


### **2. Create Temporary Table**
```sql
CREATE External TABLE temp_employees (
    emp_id INT,
    name STRING,
    age INT,
    job_role STRING,
    salary DOUBLE,
    project STRING,
    join_date STRING,
    department STRING
) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE;
```



### **3. Load Data into Temporary Tables**
```sql
LOAD DATA INPATH '/user/hive/warehouse/employees.csv' INTO TABLE temp_employees;

```

---

## **Creating and Populating the Partitioned Table**

### **1. Turn Off Strict Mode**
```sql

SET hive.exec.dynamic.partition.mode = nonstrict;
```

### **2. Create Partitioned Table for Employees**
```sql
CREATE TABLE employees_partitioned (
    emp_id INT,
    name STRING,
    age INT,
    job_role STRING,
    salary DOUBLE,
    project STRING,
    join_date STRING
) 
PARTITIONED BY (department STRING)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
STORED AS PARQUET;

```
### **2. Alter the table: run each query individually**
```sql
ALTER TABLE employees_partitioned ADD PARTITION (department='Marcketing');
ALTER TABLE employees_partitioned ADD PARTITION (department='HR');
ALTER TABLE employees_partitioned ADD PARTITION (department='IT');
ALTER TABLE employees_partitioned ADD PARTITION (department='Finance');
ALTER TABLE employees_partitioned ADD PARTITION (department='Operations');
```

### **3. move Data into Partitioned Table: run each query individually**
```sql
INSERT INTO TABLE employees_partitioned PARTITION(department='Marketing')
SELECT emp_id, name, age, job_role, salary, project, join_date
FROM temp_employees WHERE department='Marketing';

INSERT INTO TABLE employees_partitioned PARTITION(department='HR')
SELECT emp_id, name, age, job_role, salary, project, join_date
FROM temp_employees WHERE department='HR';

INSERT INTO TABLE employees_partitioned PARTITION(department='IT')
SELECT emp_id, name, age, job_role, salary, project, join_date
FROM temp_employees WHERE department='IT';

INSERT INTO TABLE employees_partitioned PARTITION(department='Finance')
SELECT emp_id, name, age, job_role, salary, project, join_date
FROM temp_employees WHERE department='Finance';

INSERT INTO TABLE employees_partitioned PARTITION(department='Operations')
SELECT emp_id, name, age, job_role, salary, project, join_date
FROM temp_employees WHERE department='Operations';


```

### **4. Check partitioned data to make sure its coreect**

```sql
SELECT * FROM employees_partitioned WHERE department = 'Marketing' LIMIT 5;

```



## **Analysis Queries**

1. **Retrieve all employees who joined after 2015**
```sql
SELECT * FROM employees_partitioned WHERE year(join_date) > 2015;
```

2. **Find the average salary of employees in each department**
```sql
SELECT department, AVG(salary) AS avg_salary FROM employees_partitioned GROUP BY department;
```

3. **Identify employees working on the 'Alpha' project**
```sql
SELECT * FROM employees_partitioned WHERE project = 'Alpha';
```

4. **Count the number of employees in each job role**
```sql
SELECT job_role, COUNT(*) AS employee_count FROM employees_partitioned GROUP BY job_role;
```

5. **Retrieve employees whose salary is above the average salary of their department**
```sql
SELECT e1.* FROM employees_partitioned e1 
JOIN (SELECT department, AVG(salary) AS avg_salary FROM employees_partitioned GROUP BY department) e2 
ON e1.department = e2.department WHERE e1.salary > e2.avg_salary;
```

6. **Find the department with the highest number of employees**
```sql
SELECT department, COUNT(*) AS emp_count FROM employees_partitioned GROUP BY department ORDER BY emp_count DESC LIMIT 1;
```

7. **Check for employees with null values in any column and exclude them from analysis**
```sql
SELECT * FROM employees_partitioned WHERE emp_id IS NOT NULL AND name IS NOT NULL AND age IS NOT NULL AND job_role IS NOT NULL AND salary IS NOT NULL AND project IS NOT NULL AND join_date IS NOT NULL AND department IS NOT NULL;
```

8. **Join the employees and departments tables to display employee details along with department locations**
```sql
SELECT e.*, d.location FROM employees_partitioned e JOIN temp_departments d ON e.department = d.department_name;
```

9. **Rank employees within each department based on salary**
```sql
SELECT emp_id, name, department, salary, RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank FROM employees_partitioned;
```

10. **Find the top 3 highest-paid employees in each department**
```sql
SELECT * FROM (
    SELECT emp_id, name, department, salary, 
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank 
    FROM employees_partitioned
) ranked WHERE rank <= 3;
```

---

## **Creating hql files: type following in terminal **
```sql
echo "SELECT * FROM employees_partitioned WHERE year(join_date) > 2015;" > query1.hql
echo "SELECT department, AVG(salary) AS avg_salary FROM employees_partitioned GROUP BY department;" > query2.hql
echo "SELECT * FROM employees_partitioned WHERE project = 'Alpha';" > query3.hql
echo "SELECT job_role, COUNT(*) AS employee_count FROM employees_partitioned GROUP BY job_role;" > query4.hql
echo "SELECT e1.* FROM employees_partitioned e1 JOIN (SELECT department, AVG(salary) AS avg_salary FROM employees_partitioned GROUP BY department) e2 ON e1.department = e2.department WHERE e1.salary > e2.avg_salary;" > query5.hql
echo "SELECT department, COUNT(*) AS emp_count FROM employees_partitioned GROUP BY department ORDER BY emp_count DESC LIMIT 1;" > query6.hql
echo "SELECT * FROM employees_partitioned WHERE emp_id IS NOT NULL AND name IS NOT NULL AND age IS NOT NULL AND job_role IS NOT NULL AND salary IS NOT NULL AND project IS NOT NULL AND join_date IS NOT NULL AND department IS NOT NULL;" > query7.hql
echo "SELECT e.*, d.location FROM employees_partitioned e JOIN temp_departments d ON e.department = d.department_name;" > query8.hql
echo "SELECT emp_id, name, department, salary, RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank FROM employees_partitioned;" > query9.hql
echo "SELECT * FROM (SELECT emp_id, name, department, salary, RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank FROM employees_partitioned) ranked WHERE rank <= 3;" > query10.hql

```

---




