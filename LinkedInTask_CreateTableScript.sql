create schema linkedIn
Go
--create tables
CREATE TABLE linkedIn.Department
(
DeptNo		INT PRIMARY KEY,
DeptName	VARCHAR(20),
Location	VARCHAR(20)
)
Go
CREATE TABLE linkedIn.Employee
( 
EmployeeNo INT Primary Key,
EmployeeName VARCHAR(25) NOT NULL,
Job			VARCHAR(20) NOT NULL,
Manager		INT NOT NULL,
HireDate    Date NOT NULL,
Salary      INT NOT NULL,
Commission	INT,
DeptNo		INT NOT NULL
FOREIGN KEY (DeptNo) REFERENCES linkedIn.Department(DeptNo)
)
GO
