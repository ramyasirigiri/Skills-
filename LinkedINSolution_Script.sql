/* SQL Queries Practice */

SELECT * FROM linkedIn.Employee1
SELECT * FROM linkedIn.Department

--1) Display all the employees who are getting 2500 and excess salaries in
--department 20.
SELECT EmployeeName FROM linkedIn.Employee1
WHERE Salary>=2500  AND DeptNo=20

--2) Display all the managers working in 20 & 30 department.
SELECT EmployeeName  FROM linkedIn.Employee1
WHERE DeptNo IN (20,30) AND Job='MANAGER'

--3) Display all the managers who don’t have a manager
SELECT EmployeeNo, Manager FROM linkedIn.Employee1
WHERE  Manager IS NUll AND EmployeeNo IN (SELECT Manager FROM linkedIn.Employee1)

--4) Display all the employees who are getting some commission with their
--designation is neither MANANGER nor ANALYST
SELECT EmployeeName, Job, Commission FROM linkedIn.Employee1
WHERE (Job NOT IN ('MANANGER','ANALYST')) AND (Commission IS NOT NULL AND Commission != 0)

--5) Display all the ANALYSTs whose name doesn’t ends with ‘S’
SELECT EmployeeName FROM linkedIn.Employee1
WHERE Job ='ANALYST' AND EmployeeName NOT LIKE '%s'

--6) Display all the employees whose naming is having letter ‘E’ as the last but
--one character
SELECT EmployeeName FROM linkedIn.Employee1
WHERE EmployeeName LIKE '%E_'

--7) Display all the employees who total salary is more than 2000.
--(Total Salary = Sal + Comm)
SELECT EmployeeName,Salary,Commission, Salary+ COALESCE(Commission,0) AS Salary FROM linkedIn.Employee1
WHERE  Salary+ COALESCE(Commission,0) > 2000

--8) Display all the employees who are getting some commission in department 20
--& 30.
SELECT EmployeeName,Salary,Commission,DeptNo AS Salary FROM linkedIn.Employee1
WHERE (Commission IS NOT NULL) AND (DeptNo IN (20,30))

--9) Display all the managers whose name doesn't start with A & S
SELECT EmployeeName FROM linkedIn.Employee1
WHERE  EmployeeName NOT LIKE  '[AS]%' AND Job='MANAGER' 

--10) Display all the employees who earning salary not in the range of 2500 and
--5000 in department 10 & 20.
SELECT EmployeeName, Salary FROM linkedIn.Employee1
WHERE (Salary NOT BETWEEN 2500 AND 5000) AND (DeptNo IN(10,20)) 
--select salary from linkedIn.Employee1 WHERE DeptNo IN(10,20)

--11) Display job-wise maximum salary.
SELECT Job,MAX(Salary) AS 'Higest Salary' FROM linkedIn.Employee1
GROUP BY Job

--12) Display the departments that are having more than 3 employees
--under it.
SELECT DeptNo,COUNT(EmployeeNo) AS [Number Of Employees] FROM linkedIn.Employee1
GROUP BY DeptNo
HAVING COUNT(EmployeeNo)>3

--13) Display job-wise average salaries for the employees whose
--employee number is not from 7788 to 7790.
WITH JobWiseAvg
AS
(
SELECT Job ,AVG(Salary) AverageSalJobWise 
FROM linkedIn.Employee1 
GROUP BY Job

)
SELECT emp.EmployeeName,jo.Job, jo.AverageSalJobWise FROM JobWiseAvg Jo
RIGHT OUTER JOIN linkedIn.Employee1 emp ON emp.Job=Jo.Job
WHERE emp.EmployeeNo NOT BETWEEN 7788 AND 7790
ORDER BY Job

--14) Display department-wise total salaries for all the Managers and
--Analysts, only if the average salaries for the same is greater than or
--equal to 3000.
 
SELECT  DeptNo, 
		SUM(Salary+COALESCE(Commission,0)) [DeptWise Total Salary], 
	    CAST(AVG(Salary+COALESCE(Commission,0)) AS DECIMAL(16,2)) [AVGSalDeptWise]
FROM linkedIn.Employee1
WHERE Job IN ('MANAGER','ANALYST')
GROUP BY DeptNo
HAVING CAST(AVG(Salary+COALESCE(Commission,0)) AS DECIMAL(16,2))>=SUM(Salary+COALESCE(Commission,0))

--Creating table Skill, 
CREATE TABLE linkedIn.Skill
(
	ID INT,
	SkillName varchar(15)
)
GO
INSERT INTO linkedIn.Skill(ID,SkillName)
VALUES (101,'ORACLE'),
	   (102,'ORACLE'),
	   (103,'ORACLE'),
	   (101,'ORACLE'),
	   (101,'JAVA'),
	   (102,'JAVA'),
	   (102,'JAVA'),
	   (103,'JAVA'),
	   (103,'JAVA'),
	   (101,'JAVA'),
	   (101,'JAVA'),
	   (101,'ORACLE'),
	   (101,'VB'),
	   (102,'ASP')

--15) Select only the duplicate records along-with their count.
SELECT 
	 ID 
	,SkillName
	,COUNT(*) [CountOfRecords] 
FROM linkedIn.Skill
GROUP BY ID,SkillName
HAVING COUNT(*)>1 
--16) Select only the non-duplicate records.
SELECT 
	 ID 
	,SkillName
	,COUNT(*) [CountOfRecords] 
FROM linkedIn.Skill
GROUP BY ID,SkillName
HAVING COUNT(*)=1 

--17) Select only the duplicate records that are duplicated only once.
SELECT 
	 ID 
	,SkillName
	,COUNT(*) [CountOfRecords] 
FROM linkedIn.Skill
GROUP BY ID,SkillName
HAVING COUNT(*)=2

--18) Select only the duplicate records that are not having the id=101.
SELECT 
	 ID 
	,SkillName
	,COUNT(*) [CountOfRecords] 
FROM linkedIn.Skill
GROUP BY ID,SkillName
HAVING COUNT(*)>1 AND ID !=101

--19)Display all the employees who are earning more than all the managers.
SELECT   EmployeeName
		,Salary+COALESCE(Commission,0) Salary 
FROM linkedIn.Employee1
WHERE Salary+COALESCE(Commission,0) >ALL(SELECT Salary+COALESCE(Commission,0) 
										 FROM linkedIn.Employee1 WHERE Job='MANAGER')

--20)Display all the employees who are earning more than any of the managers.
SELECT   EmployeeName
		,Salary+COALESCE(Commission,0) Salary 
FROM linkedIn.Employee1
WHERE Salary+COALESCE(Commission,0) >ANY(SELECT Salary+COALESCE(Commission,0) 
										 FROM linkedIn.Employee1 WHERE Job='MANAGER')
--21)Select employee number, job & salaries of all the Analysts who are earning more than any of the managers.
SELECT   EmployeeNo
		,Job
		,Salary+COALESCE(Commission,0) Salary 
FROM linkedIn.Employee1 --WHERE Job='MANAGER'
WHERE Job='Analyst' AND (Salary+COALESCE(Commission,0) >ANY(SELECT Salary+COALESCE(Commission,0) 
										 FROM linkedIn.Employee1 WHERE Job='MANAGER'))
--22)Select all the employees who work in DALLAS.

SELECT EmployeeName,DeptNo FROM linkedIn.Employee1
WHERE DeptNo=(SELECT DeptNo FROM linkedIn.Department WHERE Location='Dallas')

--23)Select department name & location of all the employees working for CLARK.
--select * FROM linkedIn.Department
SELECT * FROM linkedIn.Employee1
SELECT EmployeeNo,EmployeeName, DeptName,Location,Manager FROM linkedIn.Employee1 emp
LEFT OUTER JOIN linkedIn.Department dept ON emp.DeptNo=dept.DeptNo
WHERE Manager=(SELECT EmployeeNo FROM linkedIn.Employee1 WHERE EmployeeName='CLARK')

--24)Select all the departmental information for all the managers
SELECT EmployeeName
	  ,DeptName
	  ,Location 
FROM linkedIn.Employee1 emp
LEFT OUTER JOIN linkedIn.Department dept ON emp.DeptNo=dept.DeptNo
WHERE Job='MANAGER'

--25)Display the first maximum salary.
SELECT TOP 1 
	(Salary)
FROM linkedIn.Employee1
ORDER BY (Salary) desc

--26)Display the second maximum salary.
 with HighToLowSal
 AS
 (
 SELECT  
	(Salary),
	DENSE_RANK() over(order by salary DESC) AS High_Low
FROM linkedIn.Employee1
)
select* FROM HighToLowSal WHERE High_Low=2
--27)Display the third maximum salary.
 with HighToLowSal
 AS
 (
 SELECT  
	(Salary),
	DENSE_RANK() over(order by salary DESC) AS High_Low
FROM linkedIn.Employee1
)
select * FROM HighToLowSal 
WHERE High_Low=3

--28)Display all the managers & clerks who work in Accounts and Marketing departments. 
SELECT  EmployeeName,Job 
FROM linkedIn.Employee1 
WHERE (Job IN ('MANAGER','CLERK')) AND (DeptNo IN (SELECT DeptNo FROM linkedIn.Department 
													WHERE DeptName IN('Accounting','Sales'))) 

--29)Display all the salesmen who are not located at DALLAS.
SELECT  EmployeeName 
FROM linkedIn.Employee1 
WHERE (Job ='SALESMAN') AND (DeptNo IN (SELECT DeptNo FROM linkedIn.Department 
													WHERE DeptName LIKE 'Sales' AND Location!='Dallas')) 

--30) Get all the employees who work in the same departments as of SCOTT.
SELECT EmployeeName,
       DeptNo 
FROM linkedIn.Employee1
WHERE DeptNo=(SELECT DeptNo FROM linkedIn.Employee1 WHERE EmployeeName LIKE 'SCOTT')

--31) Select all the employees who are earning same as SMITH.
SELECT EmployeeName,
	   Salary 
FROM linkedIn.Employee1
WHERE Salary+COALESCE(Commission,0) = (SELECT Salary+COALESCE(Commission,0) FROM linkedIn.Employee1 
										WHERE EmployeeName LIKE 'SMITH')
--32) Display all the employees who are getting some commission in
--marketing department where the employees have joined only on weekdays.
SELECT EmployeeName,
       Commission,
	   DeptNo, 
	   HireDate,
	   DATEPART(DW,HireDate) 
FROM linkedIn.Employee1
WHERE (Commission>0) AND (DATEPART(DW,HireDate) IN (2,3,4,5,6)) AND (DeptNo = (SELECT DeptNo FROM linkedIn.Department 
								 WHERE DeptName LIKE 'Sales'))
--33) Display all the employees who are getting more than the
--average salaries of all the employees.
SELECT  EmployeeName, 
		Salary 
FROM linkedIn.Employee1
WHERE Salary+COALESCE(Commission,0) > (SELECT AVG(Salary+COALESCE(Commission,0)) 
										FROM linkedIn.Employee1)
--34)Display all the managers & clerks who work in Accounts and Marketing departments.
SELECT  emp.EmployeeName 
		,emp.Job
	    ,dept.DeptName 
FROM linkedIn.Employee1 emp
INNER JOIN linkedIn.Department dept ON emp.DeptNo=dept.DeptNo
WHERE Job IN('MANAGER','CLERK') AND DeptName IN('Accounting','Sales')

--35)Display all the salesmen who are not located at DALLAS.
SELECT emp.EmployeeName
      ,emp.Job
	  ,dept.Location
FROM linkedIn.Employee1 emp
LEFT OUTER JOIN linkedIn.Department dept ON emp.DeptNo=dept.DeptNo
WHERE emp.Job='SALESMAN' AND dept.Location NOT LIKE 'Dallas' 

--36)Select department name & location of all the employees working for CLARK.
SELECT emp.EmployeeName
      ,emp.Job
	  ,dept.DeptName
	  ,dept.Location
FROM linkedIn.Employee1 emp
LEFT OUTER JOIN linkedIn.Department dept ON emp.DeptNo=dept.DeptNo
WHERE emp.Manager=(SELECT EmployeeNo FROM linkedIn.Employee1 
					WHERE EmployeeName='CLARK')

--37)Select all the departmental information for all the managers
SELECT emp.EmployeeName
      ,emp.Job
	  ,dept.DeptName
	  ,dept.Location
FROM linkedIn.Employee1 emp
LEFT OUTER JOIN linkedIn.Department dept ON emp.DeptNo=dept.DeptNo
WHERE emp.Job='MANAGER'

--38)Select all the employees who work in DALLAS.
SELECT emp.EmployeeName
      ,emp.Job
	  ,dept.DeptName
	  ,dept.Location
FROM linkedIn.Employee1 emp
LEFT OUTER JOIN linkedIn.Department dept ON emp.DeptNo=dept.DeptNo
WHERE Dept.Location='Dallas'

--39) Delete the records from the DEPT table that don’t have matching records in EMP
DELETE 
FROM linkedIn.Department 
WHERE Deptno=(SELECT dept.DeptNo FROM linkedIn.Department dept 
			  LEFT OUTER JOIN linkedIn.Employee1 emp  ON emp.DeptNo=dept.DeptNo
			  WHERE emp.DeptNo IS NULL) 
---Insert A record INTO linkedIn.Department
INSERT INTO linkedIn.Department
VALUES (40,'Operation','Canada')

--40)Display all the departmental information for all the existing employees and if
--a department has no employees display it as “No employees”.
SELECT COALESCE(emp.EmployeeName,'No employees') AS EmployeeNames
      --,emp.Job
	  ,dept.DeptName
	  ,dept.Location
FROM linkedIn.Department dept
LEFT OUTER JOIN linkedIn.Employee1 emp ON emp.DeptNo=dept.DeptNo

--41)Get all the matching & non-matching records from both the tables.
SELECT emp.EmployeeName
	  ,dept.DeptName
	  ,dept.DeptNo AS DeptNoFromDeptTab
	  ,dept.DeptNo AS DeptNoFromEmpTab
	  ,emp.Job
	  ,dept.Location
FROM linkedIn.Department dept
FULL OUTER JOIN linkedIn.Employee1 emp  ON emp.DeptNo=dept.DeptNo

--42)Get only the non-matching records from DEPT table (matching records shouldn’t be selected).
SELECT emp.EmployeeName
	  ,dept.DeptName
	  ,dept.DeptNo AS DeptNoFromDeptTab
	  ,emp.DeptNo AS DeptNoFromEmpTab
	  ,emp.Job
	  ,dept.Location
FROM linkedIn.Department dept
FULL OUTER JOIN linkedIn.Employee1 emp  ON emp.DeptNo=dept.DeptNo
WHERE emp.DeptNo IS NULL

--43)Select all the employees name along with their manager names, and if an
--employee does not have a manager, display him as “CEO”.
SELECT   emp.EmployeeName AS EmployeeNames
		 ,COALESCE(man.EmployeeName,'CEO') AS ManagerName
FROM linkedIn.Employee1 AS emp
LEFT OUTER JOIN linkedIn.Employee1 AS man ON man.EmployeeNo=emp.Manager

--44)Get all the employees who work in the same departments as of SCOTT --using INNER JOIN
SELECT Distinct emp1.EmployeeName
FROM linkedIn.Employee1 AS emp1
 INNER JOIN linkedIn.Employee1 AS emp2 ON emp1.DeptNo=emp2.DeptNo
 WHERE emp2.DeptNo=(SELECT DeptNo FROM linkedIn.Employee1 WHERE EmployeeName='SCOTT')

 --45)Display all the employees who have joined before their managers.
 SELECT   emp.EmployeeName AS EmployeeName
		 ,emp.HireDate
		 ,COALESCE(man.EmployeeName,'CEO') AS ManagerName
		 ,man.HireDate
FROM linkedIn.Employee1 AS emp
LEFT OUTER JOIN linkedIn.Employee1 AS man ON man.EmployeeNo=emp.Manager
WHERE emp.HireDate<man.HireDate

--46)List all the employees who are earning more than their managers.
SELECT   emp.EmployeeName AS EmployeeName
		 ,emp.Salary+COALESCE(emp.Commission,0) AS EmployeeSal
		 ,COALESCE(man.EmployeeName,'CEO') AS ManagerName
		 ,man.Salary+COALESCE(man.Commission,0) AS ManagerSal
FROM linkedIn.Employee1 AS emp
LEFT OUTER JOIN linkedIn.Employee1 AS man ON man.EmployeeNo=emp.Manager
WHERE (emp.Salary+COALESCE(emp.Commission,0))>(man.Salary+COALESCE(man.Commission,0))

--47)Fetch all the employees who are earning same salaries.
SELECT   emp1.EmployeeName AS EmployeeName
		 --,emp1.EmployeeNo
		 --,emp2.EmployeeNo
		 --,emp1.Salary+COALESCE(emp1.Commission,0) AS EmpSal1
		 --,emp2.Salary+COALESCE(emp2.Commission,0) AS EmpSal2
FROM linkedIn.Employee1 AS emp1
LEFT OUTER JOIN linkedIn.Employee1 AS emp2 ON emp1.EmployeeNo!=emp2.EmployeeNo
WHERE emp1.Salary+COALESCE(emp1.Commission,0) = emp2.Salary+COALESCE(emp2.Commission,0) 
 
--48)Select all the employees who are earning same as SMITH.
SELECT EmployeeName 
FROM linkedIn.Employee1
WHERE Salary+COALESCE(Commission,0)= (SELECT Salary+COALESCE(Commission,0) 
									  FROM linkedIn.Employee1
									  WHERE	EmployeeName='SMITH')

--49) Display employee name , his date of joining, his manager name & his manager's date of joining.
SELECT   emp.EmployeeName AS EmployeeName
		 ,emp.HireDate
		 ,COALESCE(man.EmployeeName,'CEO') AS ManagerName
		 ,man.HireDate
FROM linkedIn.Employee1 AS emp
LEFT OUTER JOIN linkedIn.Employee1 AS man ON man.EmployeeNo=emp.Manager