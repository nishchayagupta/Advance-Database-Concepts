create database assignment5;
\c assignment5;

create table cites(bookno int, citedbookno int);
create table book(bookno int, title text, price int);
create table student(sid int, sname text);
create table major(sid int, major text);
create table buys(sid int, bookno int);
-- Data for the student relation.
INSERT INTO student VALUES(1001,'Jean');
INSERT INTO student VALUES(1002,'Maria');
INSERT INTO student VALUES(1003,'Anna');
INSERT INTO student VALUES(1004,'Chin');
INSERT INTO student VALUES(1005,'John');
INSERT INTO student VALUES(1006,'Ryan');
INSERT INTO student VALUES(1007,'Catherine');
INSERT INTO student VALUES(1008,'Emma');
INSERT INTO student VALUES(1009,'Jan');
INSERT INTO student VALUES(1010,'Linda');
INSERT INTO student VALUES(1011,'Nick');
INSERT INTO student VALUES(1012,'Eric');
INSERT INTO student VALUES(1013,'Lisa');
INSERT INTO student VALUES(1014,'Filip');
INSERT INTO student VALUES(1015,'Dirk');
INSERT INTO student VALUES(1016,'Mary');
INSERT INTO student VALUES(1017,'Ellen');
INSERT INTO student VALUES(1020,'Ahmed');
-- Data for the book relation.
INSERT INTO book VALUES(2001,'Databases',40);
INSERT INTO book VALUES(2002,'OperatingSystems',25);
INSERT INTO book VALUES(2003,'Networks',20);
INSERT INTO book VALUES(2004,'AI',45);
INSERT INTO book VALUES(2005,'DiscreteMathematics',20);
INSERT INTO book VALUES(2006,'SQL',25);
INSERT INTO book VALUES(2007,'ProgrammingLanguages',15);
INSERT INTO book VALUES(2008,'DataScience',50);
INSERT INTO book VALUES(2009,'Calculus',10);
INSERT INTO book VALUES(2010,'Philosophy',25);
INSERT INTO book VALUES(2012,'Geometry',80);
INSERT INTO book VALUES(2013,'RealAnalysis',35);
INSERT INTO book VALUES(2011,'Anthropology',50);
-- Data for the buys relation.
INSERT INTO buys VALUES(1001,2002);
INSERT INTO buys VALUES(1001,2007);
INSERT INTO buys VALUES(1001,2009);
INSERT INTO buys VALUES(1001,2011);
INSERT INTO buys VALUES(1001,2013);
INSERT INTO buys VALUES(1002,2001);
INSERT INTO buys VALUES(1002,2002);
INSERT INTO buys VALUES(1002,2007);
INSERT INTO buys VALUES(1002,2011);
INSERT INTO buys VALUES(1002,2012);
INSERT INTO buys VALUES(1002,2013);
INSERT INTO buys VALUES(1003,2002);
INSERT INTO buys VALUES(1003,2007);
INSERT INTO buys VALUES(1003,2011);
INSERT INTO buys VALUES(1003,2012);
INSERT INTO buys VALUES(1003,2013);
INSERT INTO buys VALUES(1004,2006);
INSERT INTO buys VALUES(1004,2007);
INSERT INTO buys VALUES(1004,2008);
INSERT INTO buys VALUES(1004,2011);
INSERT INTO buys VALUES(1004,2012);
INSERT INTO buys VALUES(1004,2013);
INSERT INTO buys VALUES(1005,2007);
INSERT INTO buys VALUES(1005,2011);
INSERT INTO buys VALUES(1005,2012);
INSERT INTO buys VALUES(1005,2013);
INSERT INTO buys VALUES(1006,2006);
INSERT INTO buys VALUES(1006,2007);
INSERT INTO buys VALUES(1006,2008);
INSERT INTO buys VALUES(1006,2011);
INSERT INTO buys VALUES(1006,2012);
INSERT INTO buys VALUES(1006,2013);
INSERT INTO buys VALUES(1007,2001);
INSERT INTO buys VALUES(1007,2002);
INSERT INTO buys VALUES(1007,2003);
INSERT INTO buys VALUES(1007,2007);
INSERT INTO buys VALUES(1007,2008);
INSERT INTO buys VALUES(1007,2009);
INSERT INTO buys VALUES(1007,2010);
INSERT INTO buys VALUES(1007,2011);
INSERT INTO buys VALUES(1007,2012);
INSERT INTO buys VALUES(1007,2013);
INSERT INTO buys VALUES(1008,2007);
INSERT INTO buys VALUES(1008,2011);
INSERT INTO buys VALUES(1008,2012);
INSERT INTO buys VALUES(1008,2013);
INSERT INTO buys VALUES(1009,2001);
INSERT INTO buys VALUES(1009,2002);
INSERT INTO buys VALUES(1009,2011);
INSERT INTO buys VALUES(1009,2012);
INSERT INTO buys VALUES(1009,2013);
INSERT INTO buys VALUES(1010,2001);
INSERT INTO buys VALUES(1010,2002);
INSERT INTO buys VALUES(1010,2003);
INSERT INTO buys VALUES(1010,2011);
INSERT INTO buys VALUES(1010,2012);
INSERT INTO buys VALUES(1010,2013);
INSERT INTO buys VALUES(1011,2002);
INSERT INTO buys VALUES(1011,2011);
INSERT INTO buys VALUES(1011,2012);
INSERT INTO buys VALUES(1012,2011);
INSERT INTO buys VALUES(1012,2012);
INSERT INTO buys VALUES(1013,2001);
INSERT INTO buys VALUES(1013,2011);
INSERT INTO buys VALUES(1013,2012);
INSERT INTO buys VALUES(1014,2008);
INSERT INTO buys VALUES(1014,2011);
INSERT INTO buys VALUES(1014,2012);
INSERT INTO buys VALUES(1017,2001);
INSERT INTO buys VALUES(1017,2002);
INSERT INTO buys VALUES(1017,2003);
INSERT INTO buys VALUES(1017,2008);
INSERT INTO buys VALUES(1017,2012);
INSERT INTO buys VALUES(1020,2012);
-- Data for the cites relation.
INSERT INTO cites VALUES(2012,2001);
INSERT INTO cites VALUES(2008,2011);
INSERT INTO cites VALUES(2008,2012);
INSERT INTO cites VALUES(2001,2002);
INSERT INTO cites VALUES(2001,2007);
INSERT INTO cites VALUES(2002,2003);
INSERT INTO cites VALUES(2003,2001);
INSERT INTO cites VALUES(2003,2004);
INSERT INTO cites VALUES(2003,2002);
INSERT INTO cites VALUES(2012,2005);
-- Data for the major relation.
INSERT INTO major VALUES(1001,'Math');
INSERT INTO major VALUES(1001,'Physics');
INSERT INTO major VALUES(1002,'CS');
INSERT INTO major VALUES(1002,'Math');
INSERT INTO major VALUES(1003,'Math');
INSERT INTO major VALUES(1004,'CS');
INSERT INTO major VALUES(1006,'CS');
INSERT INTO major VALUES(1007,'CS');
INSERT INTO major VALUES(1007,'Physics');
INSERT INTO major VALUES(1008,'Physics');
INSERT INTO major VALUES(1009,'Biology');
INSERT INTO major VALUES(1010,'Biology');
INSERT INTO major VALUES(1011,'CS');
INSERT INTO major VALUES(1011,'Math');
INSERT INTO major VALUES(1012,'CS');
INSERT INTO major VALUES(1013,'CS');
INSERT INTO major VALUES(1013,'Psychology');
INSERT INTO major VALUES(1014,'Theater');
INSERT INTO major VALUES(1017,'Anthropology');

\qecho 6,a

Select Distinct B.bookNo, B.title from Book B Natural Join Buys Y Natural Join Major M 
where
 M.sid in(Select sid from Major where major='CS' INTERSECT Select sid from Major where major='Math');

  
\qecho 6,b

Select Y.sid, Y.bookNo from Buys Y  natural join Cites C  where  C.BookNo in(Select Distinct c1.citedBookNo from cites c1 join cites c2 on(c1.citedbookNo=c2.citedBookNo and c1.bookNo<>c2.bookNo)
where exists (Select b.bookNo from Book B where b.bookNo=c1.bookNo and b.price<50)
and exists (Select b.bookNo from Book B where b.bookNo=c2.bookNo and b.price<50));

\qecho 6,c
Select Distinct Y.sid, Y.bookNo, Y1.bookNo from Buys Y  join Buys Y1 on(Y.sid=Y1.sid) join Cites C 
on( C.citedbookNo=Y1.bookNo and C.bookNo=Y.bookNo ) ; 


\qecho 6,d
Create or replace view booksNotPresent As Select bookNo from book Except Select citedBookNo from Cites;
												  								
Select Distinct S.sid, S.sname from Student S join Buys Y on (S.sid=Y.sid) join booksNotPresent B 
on(Y.bookNo=B.bookNo);


\qecho 6,e
Create or replace view highestPrice as (Select price from book
Except
Select B.price from Book B , Book B1  where Not B.price>=B1.price);		
												  
Select Distinct B.bookNo, B.title  from Book B join Buys Y on(B.bookNo=Y.bookNo) 
join Major M on(Y.sid = M.sid and M.major='CS' ) join highestPrice H on(H.price=B.price);

\qecho 6,f
Create or replace View getCitedBook As 
Select C.citedBookNo from Cites C join Book B on(C.bookNo=B.bookNo and B.price>50)
Except 
Select C.citedBookNo from Cites C join Book B on(C.bookNo=B.bookNo and B.price<=50);

Select B.bookNo, B.title from Book B join getCitedBook C on(C.citedBookNo=B.BookNo);

\qecho 6,g
Create or replace View getBook As
Select Distinct C.citedBookNo from Cites C join Book B on(C.bookNo=B.bookNo and B.price>50);

Select Distinct B.bookNo, B.title from Book B where    not exists
(Select citedBookNo from getBook where B.bookNo=citedBookNo);


\qecho 6,h
select distinct p.sid, p.bookN
from (select Y.sid, Y.bookno, B.bookno as bookN
from Buys Y
cross join Book B
except
select S.sid, C.bookno, C.citedbookno
from Student S
cross join Cites C) p;

\qecho 6,i
Create or replace function bookBoughtByStudent(id INTEGER) RETURNS TABLE(bookNo INTEGER) 
AS $$ Select Distinct Y.BookNo from Buys Y where Y.Sid = id;$$ LANGUAGE SQL;

Select Distinct S.sid, S1.sid from Student S cross join Student S1 
where  S.sid<>S1.sid and not exists(Select * from bookBoughtByStudent(S.sid) INTERSECT Select * from bookBoughtByStudent(S1.sid));

\qecho 6,j
Create or replace function studentBoughtBooks(bno INTEGER) RETURNS TABLE(sid INTEGER) 
AS $$ Select Distinct Y.sid from Buys Y join Major M on(Y.sid=M.sid) where Y.bookNo = bno and M.major='CS';$$ LANGUAGE SQL;

Select B1.bookNo, B2.bookNo from Book B1 cross join Book B2 
where B1.bookNo<>B2.bookNo and 
 exists
((Select * from studentBoughtBooks(B1.bookNo) UNION Select * from studentBoughtBooks(B2.bookNo))EXCEPT(Select * from studentBoughtBooks(B1.bookNo) INTERSECT Select * from studentBoughtBooks(B2.bookNo)));
																													 

\c postgres;
drop database assignment5;

 