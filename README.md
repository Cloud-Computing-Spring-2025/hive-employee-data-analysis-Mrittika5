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
   - Repeat for `departments.csv`.


  


## **Creating Temporary Tables in Hive**

### **1. Open Hue Query Editor**


### **2. Create Temporary Tables**
```sql
CREATE TABLE temp_employees (
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

```sql
CREATE TABLE temp_departments (
    dept_id INT,
    department_name STRING,
    location STRING
) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE;
```

### **3. Load Data into Temporary Tables**
```sql
LOAD DATA INPATH '/user/hive/warehouse/employees.csv' INTO TABLE temp_employees;
LOAD DATA INPATH '/user/hive/warehouse/departments.csv' INTO TABLE temp_departments;
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

### **3. move Data into Partitioned Table**
```sql
INSERT OVERWRITE TABLE employees_partitioned PARTITION (department)
SELECT emp_id, name, age, job_role, salary, project, join_date, department
FROM temp_employees;

```

### **4. Alter Table to Add Partitions**

```sql
MSCK REPAIR TABLE employees_partitioned;

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

## **Pushing Files to GitHub**
```sh
git init
git add .
git commit -m "Added HQL queries and output files"
git branch -M main
git remote add origin <your_github_repo_url>
git push origin main
```

---

## **Final Notes**
✅ Data successfully partitioned and moved.
✅ Queries executed and outputs saved.
✅ All files (`.hql`, `output.txt`, `README.md`) pushed to GitHub.

🚀 Your project is now complete! 🎉

