-- write a query
-- Question 1: Insert yourself as a New Borrower. Do not provide the Card_no in your query.
INSERT INTO BORROWER (Name, Address, Phone)
VALUES ('BoyapallyKopparthi', '848Mitchell', '1234567890');

SET SQL_SAFE_UPDATES = 0;
-- Question 2: Update your phone number to (837) 721-8965
UPDATE BORROWER
SET Phone = '(837) 721-8965'
WHERE Name = 'BoyapallyKopparthi';

-- Question 3: Increase the number of book_copies by 1 for the ‘East Branch’
UPDATE BOOK_COPIES
SET No_Of_Copies = No_Of_Copies + 1
WHERE Branch_Id = (SELECT Branch_Id FROM LIBRARY_BRANCH WHERE Branch_Name = 'East Branch');


-- Question 4-a: Insert a new BOOK with the following info: Title: ‘Harry Potter and the Sorcerer's Stone’ ; Book_author: ‘J.K. Rowling’
INSERT INTO BOOK (Title)
VALUES ('Harry Potter and the Sorcerer''s Stone');
INSERT INTO BOOK_AUTHORS(Book_Id,Author_Name)
VALUES ((select Book_Id from BOOK where Title = 'Harry Potter and the Sorcerer''s Stone' ) ,'J.K. Rowling');

-- Question 4-b: You also need to insert the following branches
INSERT INTO LIBRARY_BRANCH(Branch_Name,Branch_Address)
VALUES ('North Branch','456 NW, Irving, TX 76100'),
	   ('UTA Branch','123 Cooper St, Arlington TX 76101');
select * from LIBRARY_BRANCH;



 -- Question 5: Return all Books that were loaned between March 5, 2022 until March 23, 2022. List Book title and Branch name, and how many days it was borrowed for. [10 points]
SELECT B.Title, LB.Branch_Name, DATEDIFF(BL.Due_Date, BL.Date_Out) AS Days_Borrowed
FROM BOOK_LOANS BL
JOIN BOOK B ON BL.Book_Id = B.Book_Id
JOIN LIBRARY_BRANCH LB ON BL.Branch_Id = LB.Branch_Id
WHERE BL.Date_Out BETWEEN '2022-03-05' AND '2022-03-23';

-- Question 6: Return a List borrower names, that have books not returned. [3 points]
SELECT BR.Name
FROM BORROWER BR
JOIN BOOK_LOANS BL ON BR.Card_No = BL.Card_No
WHERE BL.Returned_date IS NULL;
	
-- Question 7: Create a report that will return all branches with the number of books borrowed per branch separated by if they have been returned, still borrowed, or late. [15 points]
SELECT LB.Branch_Name,count(*) AS count,
SUM(CASE WHEN BL.Returned_date IS NOT NULL THEN 1 ELSE 0 END) AS Returned,
SUM(CASE WHEN BL.Returned_date IS NULL AND BL.Due_Date >= CURDATE() THEN 1 ELSE 0 END) AS Still_Borrowed,
SUM(CASE WHEN BL.Returned_date IS NOT NULL AND BL.Due_Date < BL.Returned_Date THEN 1 ELSE 0 END) AS Late
FROM LIBRARY_BRANCH LB
JOIN BOOK_LOANS BL ON LB.Branch_Id = BL.Branch_Id
GROUP BY LB.Branch_Name;

-- Question 8: What is the maximum number of days a book has been borrowed. [2 points]
SELECT MAX(DATEDIFF(BL.Due_Date, BL.Date_Out)) AS Max_Days_Borrowed
FROM BOOK_LOANS BL;

-- Question 9: Create a report for Ethan Martinez with all the books they borrowed. List the book title and author. Also, calculate the number of days each book was borrowed for and if any book is late in return date. Order the results by the date_out. [6 points]
SELECT B.Title, B.Book_Publisher, DATEDIFF(BL.Due_Date, BL.Date_Out) AS Days_Borrowed,
CASE WHEN BL.Returned_date IS NULL AND BL.Due_Date < CURDATE() THEN 'Yes' ELSE 'No' END AS Late
FROM BOOK_LOANS BL
JOIN BOOK B ON BL.Book_Id = B.Book_Id
JOIN BORROWER BR ON BL.Card_No = BR.Card_No
WHERE BR.Name = 'Ethan Martinez'
ORDER BY BL.Date_Out;

-- Question 10: Return all borrowers and their addresses that borrowed a book. [3 points]
SELECT DISTINCT  BR.Name, BR.Address
FROM BORROWER BR
JOIN BOOK_LOANS BL ON BR.Card_No = BL.Card_No;