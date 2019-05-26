create database assignment2;


\c assignment2;

--Table Creation Statements

create table book (
  bookno int,
  title  text,
  price  int,
  primary key (bookno)
);


create table student (
  sid   int,
  sname text,
  primary key (sid)
);


create table cites (
  bookno      int,
  citedbookno int,
  primary key (bookno, citedbookno),
  foreign key (bookno) references book (bookno),
  foreign key (citedbookno) references book (bookno)
);

create table major (
  sid   int,
  major text,
  primary key (sid, major),
  foreign key (sid) references student (sid)
);

create table buys (
  sid    int,
  bookno int,
  primary key (sid, bookno),
  foreign key (sid) references student (sid),
  foreign key (bookno) references book (bookno)
);


--Populating Tables
insert into student
values (1001, 'Jean'),
       (1002, 'Maria'),
       (1003, 'Anna'),
       (1004, 'Chin'),
       (1005, 'John'),
       (1006, 'Ryan'),
       (1007, 'Catherine'),
       (1008, 'Emma'),
       (1009, 'Jan'),
       (1010, 'Linda'),
       (1011, 'Nick'),
       (1012, 'Eric'),
       (1013, 'Lisa'),
       (1014, 'Filip'),
       (1015, 'Dirk'),
       (1016, 'Mary'),
       (1017, 'Ellen'),
       (1020, 'Ahmed');


insert into book
values (2001, 'Databases', 40),
       (2002, 'OperatingSystems', 25),
       (2003, 'Networks', 20),
       (2004, 'AI', 45),
       (2005, 'DiscreteMathematics', 20),
       (2006, 'SQL', 25),
       (2007, 'ProgrammingLanguages', 15),
       (2008, 'DataScience', 50),
       (2009, 'Calculus', 10),
       (2010, 'Philosophy', 25),
       (2012, 'Geometry', 80),
       (2013, 'RealAnalysis', 35),
       (2011, 'Anthropology', 50);

insert into buys
values (1001, 2002),
       (1001, 2007),
       (1001, 2009),
       (1001, 2011),
       (1001, 2013),
       (1002, 2001),
       (1002, 2002),
       (1002, 2007),
       (1002, 2011),
       (1002, 2012),
       (1002, 2013),
       (1003, 2002),
       (1003, 2007),
       (1003, 2011),
       (1003, 2012),
       (1003, 2013),
       (1004, 2006),
       (1004, 2007),
       (1004, 2008),
       (1004, 2011),
       (1004, 2012),
       (1004, 2013),
       (1005, 2007),
       (1005, 2011),
       (1005, 2012),
       (1005, 2013),
       (1006, 2006),
       (1006, 2007),
       (1006, 2008),
       (1006, 2011),
       (1006, 2012),
       (1006, 2013),
       (1007, 2001),
       (1007, 2002),
       (1007, 2003),
       (1007, 2007),
       (1007, 2008),
       (1007, 2009),
       (1007, 2010),
       (1007, 2011),
       (1007, 2012),
       (1007, 2013),
       (1008, 2007),
       (1008, 2011),
       (1008, 2012),
       (1008, 2013),
       (1009, 2001),
       (1009, 2002),
       (1009, 2011),
       (1009, 2012),
       (1009, 2013),
       (1010, 2001),
       (1010, 2002),
       (1010, 2003),
       (1010, 2011),
       (1010, 2012),
       (1010, 2013),
       (1011, 2002),
       (1011, 2011),
       (1011, 2012),
       (1012, 2011),
       (1012, 2012),
       (1013, 2001),
       (1013, 2011),
       (1013, 2012),
       (1014, 2008),
       (1014, 2011),
       (1014, 2012),
       (1017, 2001),
       (1017, 2002),
       (1017, 2003),
       (1017, 2008),
       (1017, 2012),
       (1020, 2012);


insert into cites
values (2012, 2001),
       (2008, 2011),
       (2008, 2012),
       (2001, 2002),
       (2001, 2007),
       (2002, 2003),
       (2003, 2001),
       (2003, 2004),
       (2003, 2002);


INSERT INTO major
VALUES (1001, 'Math'),
       (1001, 'Physics'),
       (1002, 'CS'),
       (1002, 'Math'),
       (1003, 'Math'),
       (1004, 'CS'),
       (1006, 'CS'),
       (1007, 'CS'),
       (1007, 'Physics'),
       (1008, 'Physics'),
       (1009, 'Biology'),
       (1010, 'Biology'),
       (1011, 'CS'),
       (1011, 'Math'),
       (1012, 'CS'),
       (1013, 'CS'),
       (1013, 'Psychology'),
       (1014, 'Theater'),
       (1017, 'Anthropology');

\qecho 'Q. 1 a (Approach : Selected bookno and title from the relation book by first selecting the books which have price more than 10 and then match the entries of these books in buys table for students who major in CS or Math)'

-- 1.a
select distinct A.bookno, A.title
from book A,
     buys B,
     student C,
     major D
where A.price > 10
  and B.bookno = A.bookno
  and B.sid = C.sid
  and B.sid = D.sid
  and (D.major = 'CS' or D.major = 'Math');


\qecho 'Q. 1 b (Approach : Used IN to select the bookno from buys relation for students who major in CS or Math and applied price comparison outside in the main loop)'
-- 1.b
select distinct A.bookno, A.title
from book A,
     buys B
where price > 10
  and A.bookno = B.bookno
  and B.bookno in (select distinct bookno
                   from buys
                   where sid in (select distinct sid
                                 from major
                                 where major.major = 'CS'
                                    or major.major = 'Math'));

\qecho 'Q. 1 c(Approach : Used SOME to select the bookno from buys relation for students who major in CS or Math and applied price comparison outside in the main loop)'
-- 1.c
select distinct A.bookno, A.title
from book A,
     buys B
where price > 10
  and A.bookno = B.bookno
  and B.bookno = some(select distinct bookno
                      from buys
                      where sid = some(select distinct sid
                                       from major
                                       where major.major = 'CS'
                                          or major.major = 'Math'));

\qecho 'Q. 1 d(Approach : Used EXISTS to select the bookno from buys relation for students who major in CS or Math and applied price comparison outside in the main loop)'
-- 1.d
select distinct A.bookno, A.title
from book A,
     buys B
where price > 10
  and A.bookno = B.bookno
  and exists(select distinct bookno
             from buys
             where exists(select distinct sid
                          from major
                          where major.major = 'CS'
                             or major.major = 'Math'));


--------------------------------------------------------------------------------------------------------------------------------
\qecho 'Q. 2 a (Approach : Selected the IDs and names of all students and used EXCEPT to remove the students who purchased any book over the price of 10 )'
-- 2.a
SELECT DISTINCT A.sid, A.sname
FROM student A
    EXCEPT
SELECT DISTINCT A.sid, A.sname
from student A,
     Book B,
     buys C
where A.sid = C.sid
  and C.bookno = B.bookno
  and B.price > 10;

\qecho 'Q. 2 b (Approach : Selected the IDs and names of all students and used NOT IN to remove the students who purchased any book over the price of 10 )'
-- 2.b
select distinct A.sid, A.sname
from student A
where A.sid not in (select distinct sid from buys where bookno not in (select bookno from book where price <= 10));

\qecho 'Q. 2 c (Approach : Selected the IDs and names of all students and used != ALL to remove the students who purchased any book over the price of 10 )'
-- 2.c
SELECT DISTINCT A.sid, A.sname
FROM student A
WHERE A.sid != ALL (
	SELECT B.sid
	FROM buys B
	WHERE B.bookno IN(
		SELECT C.bookno
		FROM book C
		WHERE C.price > 10
	)
);


\qecho 'Q. 2 d (Approach : Selected the IDs and names of all students and used NOT EXISTS to remove the students who purchased any book over the price of 10 )'
select distinct A.sid, A.sname
from student A
where not exists(select distinct B.sid, B.bookno, C.price
                 from buys B,
                      book C
                 where B.bookno = C.bookno
                   and C.price > 10
                   and B.sid = A.sid);



---------------------------------------------------------------------------------------------------------------------------------
\qecho 'Q. 3 a (Approach : Firstly selected the IDs of books which are cited by at least 2 books and then checked the price of the books which cited the book)'
--3.a

SELECT DISTINCT A.bookno, A.title, A.price
FROM book A,
     cites B,
     cites C,
     book D,
     book E
where C.bookno != B.bookno
  and C.citedbookno = B.citedbookno
  and A.bookno = B.citedbookno
  and A.bookno = C.citedbookno
  and D.bookno = B.bookno
  and E.bookno = C.bookno
  and D.price > 15
  and E.price > 15;


\qecho 'Q. 3 b (Approach : Used IN to select the books which are cited by 2 books that cost more than 15)'
-- 3.b
select distinct A.bookno, A.title, A.price
from book A,
     cites B
where A.bookno in (select bookno
                   from cites
                   where bookno in (select A.citedbookno
                                    from cites A,
                                         cites B,
                                         book C,
                                         book D
                                    where A.bookno != B.bookno
                                      and A.citedbookno = B.citedbookno
                                      and C.bookno = A.bookno
                                   and D.bookno = B.bookno
                                   and C.price > 15
                                   and D.price > 15));


\qecho 'Q. 3 c (Approach : Used IN to select the books which are cited by 2 books that cost more than 15)'
-- 3.c
select distinct A.bookno, A.title, A.price
from book A,
     cites B
where exists(select distinct B.citedbookno
             from cites B,
                  cites C,
                  book D,
                  book E
             where B.citedbookno = C.citedbookno
               and B.bookno != C.bookno
               and B.citedbookno = A.bookno
          and D.bookno = B.bookno
          and E.bookno = C.bookno
          and D.price > 15
          and E.price > 15);



---------------------------------------------------------------------------------------------------------------------------------
\qecho 'Q. 4 a (Created a temporary view which would contain the sid, sname, price involving the students who major in CS and then removed the students which have any book that cost less than the highest costing book using EXCEPT)'
-- 4.a
WITH books80 as
(select distinct A.sid, A.sname, B.price
from student A,
     book B,
     buys C,
     major D
where A.sid = C.sid
  and C.bookno = B.bookno
and A.sid = D.sid and D.major = 'CS'
EXCEPT
select distinct A.sid, A.sname, B.price
from student A,
     book B,
     book C,
     buys D,
     major E
where B.bookno != C.bookno
  and A.sid = D.sid
  and D.bookno = B.bookno
and C.price > B.price and A.sid = E.sid and E.major = 'CS') select sid, sname from books80;

\qecho 'Q. 4 b (Approach : used IN to select the bookno which has the most price amongst all using the ALL operator)'
-- 4.b
select distinct A.sid, A.sname
from student A,
     book B,
     buys C,
     major D
where A.sid = C.sid
and B.bookno = C.bookno
and A.sid = D.sid
and D.major = 'CS'
and C.bookno in (select distinct bookno from book where price >= all(select price from book));


---------------------------------------------------------------------------------------------------------------------------------
\qecho 'Q. 5 (Approach : selected the books which are cited by any book that does not have the lowest price. First, i found out the book with the lowest price and inside the subqyery, used NOT IN to remove and select the right book from cites relation)'
-- 5
select distinct A.bookno, A.title
from book A
where A.bookno in (select distinct A.citedbookno
                   from cites A,
                        book B
                   where A.bookno = B.bookno and B.bookno not in(select A.bookno from book A where price <= ALL(select price from book )));


----------------------------------------------------------------------------------------------------------------------------------

\qecho 'Q. 6 (Approach : firstly selected students who major in more than one subject and then refined the results by sorting out the students who didnt buy any book with the lowest price)'
-- 6
select A.sid, A.sname
from student A
where A.sid in (select sid
                from major
                where sid not in (select distinct A.sid
                                  from major A,
                                       major B
                                  where A.sid = b.sid
                                    and A.major != B.major))
  and A.sid in (select distinct sid
                from buys
                where bookno =
                      ANY(select bookno from book where bookno not in (select bookno from book where price <= ALL (select price from book))));


---------------------------------------------------------------------------------------------------------------------------------

\qecho 'Q. 7'
-- 7
with LowestBookRemoved as (
select A.bookno, A.title, A.price from book A where A.bookno in (
select distinct B.bookno from book A, book B where A.price < B.price))
select D.bookno, D.title from LowestBookRemoved D where D.bookno  not in (select distinct B.bookno from LowestBookRemoved A, LowestBookRemoved B where A.price < B.price) ;


---------------------------------------------------------------------------------------------------------------------------------

\qecho 'Q. 8 (selected all the sids who have bought any book that cost more than 75 using ANY and used NOT IN to remove those records)'
-- 8
select sid, sname
from student
where sid not in (select distinct sid from buys where bookno = ANY(select bookno from book where price > 75));

----------------------------------------------------------------------------------------------------------------------------------

\qecho 'Q. 9 (Approach : selected the students which have bought all the books which cost more than 75 dollars using ALL and used IN to salect their respective named from student relation)'
--9
select distinct sid, sname
from student
where sid in (select sid from buys where bookno = ALL(select bookno from book where price > 75));


----------------------------------------------------------------------------------------------------------------------------------

\qecho 'Q. 10 (Approach : selected studentd ID and bookno and used ALL operator on price and finally matched the sid in main query and in qubquery to grab the result)'
-- 10
select A.sid, B.bookno from buys A, book B
where A.bookno = B.bookno and B.price >= all (
    select C.price from book C, buys D
    where C.bookno = D.bookno and D.sid = A.sid
);


----------------------------------------------------------------------------------------------------------------------------------

\qecho 'Q. 12 (Approach : used NOT IN to select and remove the students which have more than one book in common, Please use order by while matching the records because they are jumbled)'
-- 12
select distinct A.sid, B.sid from buys A, buys B where A.bookno = B.bookno and A.sid != B.sid
and (A.sid, B.sid) not in (select distinct A.sid, B.sid
from buys A,
     buys B,
     buys C
where A.sid = C.sid
  and A.sid != B.sid
  and B.bookno = C.bookno
  and A.bookno != B.bookno
  and (B.sid, A.bookno) in (select sid, bookno from buys)
  and (B.sid, C.bookno) in (select sid, bookno from buys));


---------------------------------------------------------------------------------------------------------------------------------

\qecho 'Q. 13 (Approach : Created a view named bookAtLeast30 which contained the books whose price is more than 30 and simply used the NOT IN operation to remove the books from the main query)'
-- 13
create view bookAtLeast30 as select * from book where price > 30;

select distinct A.sid, A.sname
from student A,
     buys B,
     buys C
where A.sid = B.sid
  and A.sid = C.sid
  and B.bookno not in (select bookno from bookAtLeast30)
  and B.bookno != C.bookno
  and C.bookno not in (select bookno from bookAtLeast30);

drop view bookAtLeast30;


---------------------------------------------------------------------------------------------------------------------------------

\qecho 'Q. 14 (Approach : Created a temporary view named bookAtLeast30 in order to perform the same operation as question 14)'
-- 14
WITH bookAtLeast30 as (select * from book where price > 30)
select distinct A.sid, A.sname
from student A,
     buys B,
     buys C
where A.sid = B.sid
  and A.sid = C.sid
  and B.bookno not in (select bookno from bookAtLeast30)
  and B.bookno != C.bookno
  and C.bookno not in (select bookno from bookAtLeast30);


\qecho 'Q. 15'
CREATE FUNCTION citedByBook(bid int)
               RETURNS TABLE(bid int , title text, price int) AS
               $$
                      SELECT A.citedbookno, B.title, B.price from cites A, book B where A.citedbookno = B.bookno and bid = A.bookno
               $$   LANGUAGE  SQL;

\qecho 'Q. 15 a (Approach : selected the books which are cited by 2001 and 2002 using the function created above)'
select distinct A.bookno, A.title, A.price
from book A
where A.bookno in (select bid from citedByBook(2001))
   and A.bookno in (select bid from citedByBook(2002));


\qecho 'Q. 15 b (Approach : Created 2 temporary views and used citedByBook function in order to find the result.)'
with citations as (select A.bookno, B.bid
                   from book A,
                        citedByBook(A.bookno) B)
select A.bookno, A.title from book A where A.bookno not in (with singleCitations as (select distinct A.bookno, A.citedbookno
from cites A,
     cites B
where A.bookno = B.bookno and A.citedbookno != B.citedbookno) select distinct A.bookno from singleCitations A);


--Connect to default database
\c postgres;

--Drop database which you created
DROP DATABASE assignment2;


