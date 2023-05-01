
-- TASK1
-- Q1 (Add an extra column ‘Late’ to the Book_Loan table)
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE BOOK_LOANS ADD COLUMN Late INT DEFAULT 0;
UPDATE BOOK_LOANS
SET Late = CASE
    WHEN (Returned_date IS NOT NULL AND Due_Date < Returned_date)  
    THEN 1
    ELSE 0
END;



Select * from BOOK_LOANS;

-- Q2 (Add an extra column ‘Late’ to the Book_Loan table)

ALTER TABLE LIBRARY_BRANCH ADD COLUMN LateFEE FLOAT(8,2) DEFAULT 10.53 ;

Select * from LIBRARY_BRANCH;

-- Q2 (Create a view vBookLoanInfo)

CREATE VIEW vBookLoanInfo AS
SELECT bl.Card_No,
       b.Name AS `Borrower Name`,
       bl.Date_Out,
       bl.Due_Date,
       bl.Returned_date,
	   DATEDIFF(IF(bl.Returned_date IS NOt NULL, bl.Returned_date, CURDATE()), bl.Date_Out) AS `TotalDays`,
       bk.Title AS `Book Title`,
       DATEDIFF(IF(bl.Returned_date > bl.Due_Date, bl.Returned_date, bl.Due_Date), bl.Due_Date) AS `Number of days later return`,
       bl.Branch_ID,
       CASE
        WHEN (bl.Returned_date IS NOT NULL AND Due_Date < Returned_date) THEN (DATEDIFF(bl.Returned_date, bl.Due_Date) * lb.lateFEE)
         ELSE 0
       END AS `LateFeeBalance`
FROM BOOK_LOANS bl
JOIN BORROWER b ON bl.Card_No = b.Card_No
JOIN BOOK bk ON bl.Book_ID = bk.Book_ID
JOIN LIBRARY_BRANCH lb on lb.Branch_Id = bl.Branch_Id;

-- drop view vBookLoanInfo;
select * from vBookLoanInfo;



use LMS;

-- TASK 2

-- 1
	SELECT * FROM BOOK;
	SELECT * FROM BOOK_LOANS;
    SELECT * FROM BORROWER;
    SELECT * FROM LIBRARY_BRANCH;
    SELECT * FROM BOOK_COPIES;
    SELECT * FROM BOOK_AUTHORS;
	
    INSERT INTO BOOK_LOANS
    VALUES ((SELECT Book_Id FROM BOOK B WHERE B.Title = "1984"),
			(SELECT Branch_Id FROM LIBRARY_BRANCH LB WHERE LB.Branch_Name ="Main Branch"),
            "123456",
            CURRENT_DATE,
            DATE_ADD(CURRENT_DATE, INTERVAL 10 DAY),
            NULL,
            0
            );
	UPDATE BOOK_COPIES
    SET No_Of_Copies = No_Of_Copies - 1
    WHERE Book_Id = (SELECT Book_Id FROM BOOK B WHERE B.Title = "1984") AND
    Branch_Id = (SELECT Branch_Id FROM LIBRARY_BRANCH LB WHERE LB.Branch_Name ="Main Branch");
    
    select b.Title as Book, br.Branch_Name as Branch,No_Of_Copies as copies from BOOK_COPIES bc
    JOIN BOOK b ON b.Book_Id = bc.Book_Id
    JOIN LIBRARY_BRANCH br ON br.Branch_Id = bc.Branch_Id;
    
-- 2
-- check same values are inserted but should not be inserted
	INSERT INTO BORROWER(Name,Address,Phone)
    VALUES("YASH","ARLINGTON","123456789");
    SELECT Card_No from BORROWER
    where Name="YASH" AND Address = "ARLINGTON" AND Phone = "123456789";
    
-- 3
	INSERT BOOK(Title,Book_Publisher)
    VALUES ("1985","Scribner");
    INSERT BOOK_AUTHORS(Book_Id,Author_Name)
    VALUES((SELECT Book_Id FROM BOOK WHERE Title = "1985" ) ,"Harper Le");
    INSERT INTO BOOK_COPIES
	SELECT (SELECT Book_Id from BOOK b where b.Title = "1985" ),Branch_Id,5 FROM LIBRARY_BRANCH;
-- 4
	select Branch_Name as BRANCH,count(*) as COUNT from BOOK_LOANS,LIBRARY_BRANCH
	where LIBRARY_BRANCH.Branch_Id = BOOK_LOANS.Branch_Id and BOOK_LOANS.Book_Id = (
	select Book_Id from BOOK where Title = "1985")
	group by Branch_Name;
-- 5
	SELECT  bl.Card_No as Borrower_ID, lb.Branch_Name as Branch,b.Title as Book,datediff(Returned_date,bl.Due_Date) as `Days late` 
    FROM BOOK_LOANS bl 
    join BOOK b on b.Book_Id = bl.Book_Id
    join LIBRARY_BRANCH lb on lb.Branch_Id = bl.Branch_Id
    WHERE Due_Date BETWEEN "2022-01-05" AND "2022-02-15" AND LATE = 1;
-- 6a 
SELECT 
	 Card_No as Borrower_ID,
     `Borrower Name`,
     CONCAT('$',LateFeeBalance ) as LateFeeBalance
from vBookLoanInfo
where `Borrower Name` LIKE '%Sophia Park%';

SELECT 
	 Card_No as Borrower_ID,
     `Borrower Name`,
     CONCAT('$',LateFeeBalance ) as LateFeeBalance
from vBookLoanInfo
where `Card_No` ='676767';

SELECT 
	 Card_No as Borrower_ID,
     `Borrower Name`,
     CONCAT('$',LateFeeBalance ) as LateFeeBalance
from vBookLoanInfo
order by LateFeeBalance DESC;

-- 6b

SELECT 
	(select Book_Id from BOOK where Title=vbl.`Book Title`) as book_id,
	`Book Title`,
    (select Book_Publisher from BOOK where Title=vbl.`Book Title`) as Book_Publisher,
	CONCAT('$', SUM(LateFeeBalance) + 0.00) as LateFeeAmount
from vBookLoanInfo as vbl
group by `Book Title` 
order by SUM(LateFeeBalance) desc;

SELECT 

	(select Book_Id from BOOK where Title=vbl.`Book Title`) as book_id,
	`Book Title`,
    (select Book_Publisher from BOOK where Title=vbl.`Book Title`) as Book_Publisher,
	CONCAT('$', SUM(LateFeeBalance) + 0.00) as LateFeeAmount
from vBookLoanInfo as vbl 
Join BOOK b on b.title = vbl.`Book Title`
group by `Book Title` 
order by SUM(LateFeeBalance) desc;


SELECT 

	(select Book_Id from BOOK where Title=vbl.`Book Title`) as book_id,
	`Book Title`,
    (select Book_Publisher from BOOK where Title=vbl.`Book Title`) as Book_Publisher,
	CONCAT('$', SUM(LateFeeBalance) + 0.00) as LateFeeAmount
from vBookLoanInfo as vbl 
Join BOOK b on b.title = vbl.`Book Title`
where book_id = 14
group by `Book Title` 
order by SUM(LateFeeBalance) desc;

SELECT 

	(select Book_Id from BOOK where Title=vbl.`Book Title`) as book_id,
	`Book Title`,
    (select Book_Publisher from BOOK where Title=vbl.`Book Title`) as Book_Publisher,
	CONCAT('$', SUM(LateFeeBalance) + 0.00) as LateFeeAmount
from vBookLoanInfo as vbl 
Join BOOK b on b.title = vbl.`Book Title`
where b.Title LIKE "%LORD%"
group by `Book Title` 
order by SUM(LateFeeBalance) desc;



-- questions:- 
-- to create view results or normal query output for 6th
-- late fee must be same for every branch or diff 
-- to create combinely or individually for 6th




