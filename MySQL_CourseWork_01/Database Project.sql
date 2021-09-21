-- create tables 
CREATE TABLE book (   
  isbn CHAR(17) NOT NULL,
  title VARCHAR(30) NOT NULL,
  author VARCHAR(30) NOT NULL,
CONSTRAINT pri_book PRIMARY KEY(isbn)); -- << isbn is book table primary key 

CREATE TABLE copy (
 `code` INT NOT NULL,
  duration TINYINT NULL,
  isbn CHAR(17) NOT NULL,
  CONSTRAINT pri_copy PRIMARY KEY(`code`), -- << primary key 
  CONSTRAINT check_copy CHECK (duration IN(7, 14, 21)),
 CONSTRAINT for_copy FOREIGN KEY(isbn) -- << foreign key 
  REFERENCES book (isbn) -- << reference
  ON UPDATE CASCADE ON DELETE CASCADE); -- << update and delete clauses 

CREATE TABLE student (
  `no` INT NOT NULL,
 `name` VARCHAR(30) NOT NULL,
  school CHAR(3) NOT NULL,
 embargo BIT(1) NOT NULL DEFAULT 0, -- << embargo can only be true or false; is defaulted to false
  CONSTRAINT pri_student PRIMARY KEY(`no`));  -- << primary key
CREATE TABLE loan (
 `code` INT NOT NULL,
 `no` INT NOT NULL,
  taken DATE,
  due DATE NOT NULL,
 `return` DATE NOT NULL,
  CONSTRAINT pri_loan PRIMARY KEY(`code`, `no`, `taken`), -- << three primary keys are declared  
  CONSTRAINT for1_loan FOREIGN KEY (`code`)  -- << foreign key is declared to create primary/ foreign key 
 REFERENCES copy (`code`)  ON UPDATE CASCADE ON DELETE CASCADE, -- << reference
  CONSTRAINT for2_loan FOREIGN KEY (`no`) -- << foreign key is declared to create primary/ foreign key 
  REFERENCES student (`no`) ON UPDATE CASCADE ON DELETE CASCADE); -- << reference

CREATE TABLE audit ( 
  `no` INT NOT NULL,
   taken DATE,
   due DATE,
 `return` DATE,
   audit_no INT NOT NULL AUTO_INCREMENT,
   CONSTRAINT pri_audit PRIMARY KEY(audit_no)); -- << audit_no is primary key

DELIMITER $$
CREATE TRIGGER loan_update 
AFTER UPDATE ON loan FOR EACH ROW
BEGIN
  IF(NEW.`return`> OLD.due) -- << if return is later than the due date then trigger activates 
THEN
   INSERT INTO audit (`no`, taken, due, `return`) -- personal data is recorded
   VALUES(NEW.`no`, NEW.taken, NEW.due, NEW.`return`); -- audit table is updated 
  END IF;
END$$
DELIMITER ;

CREATE INDEX in_loan1 ON loan (`code`); -- << index works by primary/foreign key code
CREATE INDEX in_loan2 ON loan (`no`); -- << index works by primary/foreign key no
CREATE INDEX in_forisbn ON copy (isbn); -- << index works by primary/foreign key isbn

-- CMP school view
CREATE VIEW CMP_Students 
AS
 SELECT `no`, `name`, school -- information included in view
   FROM student -- table data is sourced from
     WHERE school = 'CMP' -- constraint
     WITH CHECK OPTION; -- check option to enforce only CMP editions
-- test view with deliberately invalid input to test rejection 
UPDATE CMP_Students SET school = 'BUE';

INSERT INTO book (isbn, title, author) VALUES ('111-2-33-444444-5', 'Pro JavaFX', 'Dave Smith');        -- } 
INSERT INTO book (isbn, title, author) VALUES ('222-3-44-555555-6', 'Oracle Systems', 'Kate Roberts');  -- } insert data into book table
INSERT INTO book (isbn, title, author) VALUES ('333-4-55-666666-7', 'Expert jQuery', 'Mike Smith');  -- }

INSERT INTO copy (`code`, isbn, duration) VALUES(1011, '111-2-33-444444-5', 21); -- }
INSERT INTO copy (`code`, isbn, duration) VALUES(1012, '111-2-33-444444-5', 14); -- }
INSERT INTO copy (`code`, isbn, duration) VALUES(1013, '111-2-33-444444-5', 7);  -- } insert data into copy table
INSERT INTO copy (`code`, isbn, duration) VALUES(2011, '222-3-44-555555-6', 21); -- }
INSERT INTO copy (`code`, isbn, duration) VALUES(3011, '333-4-55-666666-7', 7);  -- }
INSERT INTO copy (`code`, isbn, duration) VALUES(3012, '333-4-55-666666-7', 14); -- }

INSERT INTO student (`no`, `name`, school, embargo) VALUES(2001, 'Mike', 'CMP', 1);  -- }
INSERT INTO student (`no`, `name`, school, embargo) VALUES(2002, 'Andy', 'CMP', 0);  -- }
INSERT INTO student (`no`, `name`, school, embargo) VALUES(2003, 'Sarah', 'ENG', 0); -- } insert data into student table
INSERT INTO student (`no`, `name`, school, embargo) VALUES(2004, 'Karen', 'ENG', 1); -- }
INSERT INTO student (`no`, `name`, school, embargo) VALUES(2005, 'Lucy', 'BUE', 0);  -- }

INSERT INTO loan (`code`, `no`, taken, due, `return`) VALUES(1011, 2002, '2018.01.10', '2018.01.31', '2018.01.31'); -- }
INSERT INTO loan (`code`, `no`, taken, due, `return`) VALUES(1011, 2002, '2018.02.05', '2018.02.26', '2018.02.23'); -- }
INSERT INTO loan (`code`, `no`, taken, due, `return`) VALUES(1011, 2003, '2018.05.10', '2018.05.31', 'NULL');       -- }
INSERT INTO loan (`code`, `no`, taken, due, `return`) VALUES(1013, 2003, '2017.03.02', '2017.03.16', '2017.03.10'); -- }  insert data into loan table
INSERT INTO loan (`code`, `no`, taken, due, `return`) VALUES(1013, 2002, '2017.08.02', '2017.08.16', '2017.08.16'); -- }
INSERT INTO loan (`code`, `no`, taken, due, `return`) VALUES(2011, 2004, '2016.02.01', '2016.02.22', '2016.02.20'); -- }
INSERT INTO loan (`code`, `no`, taken, due, `return`) VALUES(3011, 2002, '2018.07.03', '2018.07.10', 'NULL');       -- }
INSERT INTO loan (`code`, `no`, taken, due, `return`) VALUES(3011, 2005, '2017.10.10', '2017.10.17', '2017.10.20'); -- }

-- Task 1
SELECT 
    isbn, title, author
FROM
    book;      -- from the book table  
-- Task 2
SELECT  `no`, `name`, school -- select student number, name and school 
  FROM student               -- from student table 
    ORDER BY school DESC;    -- ordered by school in descending order
-- Task 3
SELECT isbn, title -- select data from isbn and title
FROM book  -- source data from book table
   WHERE author LIKE '%smith%'; -- keyword is smith 

-- Task 4
SELECT MAX(due) AS 'lastest due DATE' -- latest due date 
FROM loan;                            -- source data from loan table

-- Task 5
SELECT `no` -- select student number
  FROM loan  -- data source
   WHERE due = ( -- sub query 
    SELECT MAX(due) -- maximum due date
     FROM loan);  -- data source
     
-- Task 6 
SELECT `no`, `name` -- select student number and name
 FROM student -- data source
   WHERE `no` = ( -- perform action where student number is...
     SELECT loan.`no` -- select student number
       FROM loan  -- data source
         WHERE loan.due = ( 
          SELECT MAX(due)
           FROM loan));

-- Task 7
SELECT `no`, `code`, due -- select student number, copy code and due date
  FROM loan -- from loan table 
   WHERE (YEAR(taken) =  -- from where year taken
     YEAR(CURRENT_DATE()))-- current date
 AND (`return` IS NULL); -- book hasn’t been returned

-- Task 8
SELECT student.`no`, student.`name`  -- student number & name
  FROM student  -- data source
   INNER JOIN loan              -- } inner join  
    ON student.`no` = loan.`no` -- }
     WHERE loan.due = (   -- where loan is maximum due date
      SELECT MAX(due)
       FROM loan);

-- Task 9 
SELECT DISTINCT
    S.`no`, S.`name`, B.isbn, B.title  -- student number, name, book isbn, book title
FROM
    copy C                       -- }
        INNER JOIN               -- }
    loan L ON L.`code` = C.`code`-- }
        INNER JOIN               -- } inner join 
    student S ON L.`no` = S.`no` -- }
        INNER JOIN               -- }
    book ON C.isbn = B.isbn      -- }
WHERE   
    C.duration = 7; -- where the copy duration is 7 days

-- Task 10
SELECT B.title AS `book title`, COUNT(B.title) AS Frequency
   FROM book AS B INNER JOIN copy AS C          -- } 
     ON B.isbn = C.isbn                         -- } inner join 
     INNER JOIN loan AS L ON C.`code` = L.`code`-- }
       GROUP BY B.title; -- group by book title
       
-- Task 11
SELECT B.title AS `book title`, COUNT(B.title) AS Frequency
   FROM book AS B INNER JOIN copy AS C          -- }
     ON B.isbn = C.isbn                         -- } inner join 
     INNER JOIN L AS loan ON C.`code` = L.`code`-- }
       GROUP BY B.title  -- group by title              
        HAVING (COUNT(B.title)) > 1; -- used instead of WHERE to be used with aggregate functions

DELIMITER $$
CREATE PROCEDURE generate_loan (IN isbn CHAR (17), IN `no` INT) -- name of procedure and data tables to be targeted
  BEGIN -- start procedure 
    DECLARE cursorflag BOOLEAN DEFAULT FALSE;-- }
    
DECLARE copy_code, student_no INT;           -- } declare variables 
    DECLARE copy_duration TINYINT;           -- }
    DECLARE embargostatus BIT(1) DEFAULT 1;  -- }
     
DECLARE deployed, complete BOOLEAN; 
 
    DECLARE copycode_c CURSOR FOR    -- declare cursor value 
          SELECT copy, `code`, duration
FROM copy -- table source
              WHERE isbn = isbn_book; -- isbn = variable
    DECLARE CONTINUE HANDLER FOR NOT FOUND 
SET cursorflag = TRUE;   -- cursorflag set to true
    OPEN copycode_c ; -- open cursor
    SET embargostatus = (    -- }
        SELECT embargo       -- } embargo status is set 
FROM student                 -- }
	WHERE `no` = student_no);-- }
    
SELECT embargostatus;  
       IF(embargostatus IS NULL OR embargostatus = 1) THEN -- if embargo = yes 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'THIS STUDENT IS EITHER UNDER EMBARGO OR IS OTHERWISE UNABLE TO TAKE OUT LOANS'; -- execute signal
END IF;
    SET deployed = FALSE; -- deployed set to false
    SET copy_code = 0; -- 0 = false
    
  loanloop : LOOP -- start of loop 
      
FETCH copycode_c INTO copy_code, copy_duration; -- fetch cursor into variables
      IF complete  
            THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NO INFORMATION FOUND'; -- execute signal 
      END IF; 
      IF
        (SELECT NOT EXISTS 
(SELECT * FROM loan  -- select all data from the loan table 
           WHERE (`code` = copy_code) AND (`return IS NULL`))) -- were code is equal to copy code and return is null
           THEN
INSERT INTO loan                              -- } insert data into loan table 
		  (`code`, `no`, taken, due, `return`)-- } V variables, dates, interval copy code duration is set to null V
VALUES (copy_code, student_no, CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL copy_duration DAY), NULL);

LEAVE looploop; -- leave loan loop
      END IF;
    END LOOP; -- end loop 
  CLOSE copycode_c; -- close cursor 
 END$$ -- end procedure
DELIMITER ;
