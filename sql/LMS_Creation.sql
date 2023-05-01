show databases;

DROP DATABASE LMS ;
create database if not exists  LMS;
use  LMS;
show tables;

-- create mysql tables
CREATE TABLE PUBLISHER (
  Publisher_Name VARCHAR(50) NOT NULL,
  Phone VARCHAR(15),
  Address VARCHAR(100),
  PRIMARY KEY (Publisher_Name)
);

CREATE TABLE LIBRARY_BRANCH (
  Branch_Id INT NOT NULL AUTO_INCREMENT,
  Branch_Name VARCHAR(50) NOT NULL,
  Branch_Address VARCHAR(100),
  PRIMARY KEY (Branch_Id)
);

CREATE TABLE BORROWER (
  Card_No INT NOT NULL AUTO_INCREMENT,
  Name VARCHAR(50) NOT NULL,
  Address VARCHAR(100) NOT NULL,
  Phone VARCHAR(15) NOT NULL,
  PRIMARY KEY (Card_No),
  CONSTRAINT unique_row_combination UNIQUE(Name,Address,Phone)
);

CREATE TABLE BOOK (
  Book_Id INT NOT NULL AUTO_INCREMENT,
  Title VARCHAR(100) NOT NULL unique,
  Book_Publisher VARCHAR(50),
  PRIMARY KEY (Book_Id),
  FOREIGN KEY (Book_Publisher) REFERENCES PUBLISHER (Publisher_Name)
);

CREATE TABLE BOOK_LOANS (
  Book_Id INT NOT NULL,
  Branch_Id INT NOT NULL,
  Card_No INT NOT NULL,
  Date_Out DATE NOT NULL,
  Due_Date DATE NOT NULL,
  Returned_date DATE,
  PRIMARY KEY (Book_Id, Branch_Id, Card_No,Date_Out),
  FOREIGN KEY (Book_Id) REFERENCES BOOK (Book_Id),
  FOREIGN KEY (Branch_Id) REFERENCES LIBRARY_BRANCH (Branch_Id),
  FOREIGN KEY (Card_No) REFERENCES BORROWER (Card_No)
);

CREATE TABLE BOOK_COPIES (
  Book_Id INT NOT NULL,
  Branch_Id INT NOT NULL,
  No_Of_Copies INT NOT NULL,
  PRIMARY KEY (Book_Id, Branch_Id),
  FOREIGN KEY (Book_Id) REFERENCES BOOK (Book_Id),
  FOREIGN KEY (Branch_Id) REFERENCES LIBRARY_BRANCH (Branch_Id)
);

CREATE TABLE BOOK_AUTHORS (
  Book_Id INT NOT NULL,
  Author_Name VARCHAR(50) NOT NULL,
  PRIMARY KEY (Book_Id, Author_Name),
  FOREIGN KEY (Book_Id) REFERENCES BOOK (Book_Id)
);



