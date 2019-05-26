-- Creating database with my initials
create database assignment5;

--Connecting database
\c assignment5;


--Table Creations
create table cites(bookno int, citedbookno int);
create table book(bookno int, title text, price int);
create table student(sid int, sname text);
create table major(sid int, major text);
create table buys(sid int, bookno int);


--Table Data Insertion
INSERT INTO student
VALUES (1001, 'Jean'),
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

INSERT INTO book
VALUES (2001, 'Databases', 40),
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

INSERT INTO buys
VALUES (1001, 2002),
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


INSERT INTO cites
VALUES (2012, 2001),
       (2008, 2011),
       (2008, 2012),
       (2001, 2002),
       (2001, 2007),
       (2002, 2003),
       (2003, 2001),
       (2003, 2004),
       (2003, 2002),
       (2012, 2005);


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

\qecho 'Q. 6.a'
-- 6.a
with studentsFromCS as (select distinct S.sid from student S
                                                     NATURAL JOIN major M where M.major = 'CS'),
     studentsFromMath as (select distinct S.sid from student S
                                                       NATURAL JOIN major M where M.major = 'Math')
select distinct B.bookno, B.title
from Book B
       NATURAL JOIN Buys T
where exists(select C.sid from studentsFromCS C where C.sid = T.sid)
  and exists(select D.sid from studentsFromMath D where D.sid = T.sid);


\qecho 'Q. 6.b'
--6.b
with BooksCitedByAtleast2Books as (select distinct A.citedbookno as bookno
                                   from (select distinct C.bookno,
                                                         C.citedbookno,
                                                         C1.bookno      as bookno2,
                                                         C1.citedbookno as citesbookno2
                                         from Cites C
                                                cross join cites C1,
                                              Book B,
                                              Book B1
                                         where C.citedbookno = C1.citedbookno
                                           and C.bookno != C1.bookno
                                           and C.bookno = B.bookno
                                           and B.price < 50
                                           and C1.bookno = B1.bookno
                                           and B1.price < 50) A)
select distinct S.sid, B.bookno
from student S
       natural join buys T,
     book B
       natural join buys T1
where exists (select B1.bookno from BooksCitedByAtleast2Books B1 where B1.bookno = B.bookno)
and exists (select B2.sid, B2.bookno from buys B2 where B2.sid = S.sid and B2.bookno = B.bookno and B2.sid = S.sid and B.bookno = B2.bookno);


\qecho 'Q. 6.c'
--6.c

create or replace function bookCitedBy(book1 integer, book2 integer) returns boolean as
  $$
    select exists(select A.citedbookno from cites A where A.citedbookno = book1 and A.bookno = book2)
  $$ language sql;

select distinct A.sid, B.bookno, C.bookno
from buys A
       join buys B on A.sid = B.sid
       join buys C on A.sid = C.sid
and B.bookno != C.bookno and bookCitedBy(C.bookno, B.bookno);


\qecho 'Q. 6.d'
--6.d

With BooksNotCited as (select A.bookno from book A where not exists(select distinct citedbookno from cites where citedbookno = A.bookno))
select distinct A.sid, A.sname from student A natural join buys B where exists(select bookno from BooksNotCited where bookno = B.bookno);


\qecho 'Q. 6.e'
--6.e
with BooksBoughtByCSStudents as (select distinct A.bookno, A.price
                                 from book A
                                        natural join buys B
                                        natural join major C
                                 where C.major = 'CS')
select A.bookno, A.title
from book A
where  exists (select bookno from BooksBoughtByCSStudents where bookno = A.bookno)
  and not exists(select B.price from BooksBoughtByCSStudents B where A.price < B.price);


\qecho 'Q. 6.f'
--6.f
select distinct A.bookno, A.title
from book A cross join cites C where C.citedbookno = A.bookno
and not exists (
            select distinct B.citedbookno
            from cites B
            where  exists (select bookno from book where price <= 50 and bookno = B.bookno) and B.citedbookno = A.bookno);


\qecho 'Q. 6.g'
-- 6.g
create or replace function findCitingBooks(citedBook integer) returns table(book_citation integer) as $$
  select A.bookno from cites A where citedbookno = citedBook
$$language sql;

select A.bookno
from Book A
where not exists(select B.book_citation
                 from findCitingBooks(A.bookno) B,
                      book C
                 where B.book_citation = C.bookno and C.price > 50 );

\qecho 'Q. 6.h'
-- 6.h
Select A.sid, B.bookno
from Student A,
     Book B
where exists(
        select C.bookno, C.sid
        from buys C where C.sid = A.sid
         and not exists(select D.bookno, D.citedbookno
                         from cites D
                         where D.bookno = C.bookno
                           and B.bookno = D.citedbookno));


\qecho 'Q. 6.i'
-- 6.i
select distinct A.sid, B.sid
from Student A,
     student B
where A.sid <> B.sid
  and not exists(select C.bookno
                 from buys C
                 where C.sid = B.sid
                   and exists(select D.bookno
                              from buys D
                              where D.sid = A.sid
                                and D.bookno = C.bookno))
order by 1;

\qecho 'Q. 6.j'
--6.j
create or replace function BookSetBoughtByStudents(book_no integer) returns table(student_id integer) as $$
select distinct A.sid
from buys A
where exists(select B.sid
             from major B
             where B.major = 'CS'
               and A.sid = B.sid) and bookno = book_no;

$$ language sql;

select distinct A.bookno, B.bookno
from book A cross join
     book B
where A.bookno != B.bookno
  and (exists(select student_id from booksetboughtbystudents(A.bookno)
                  except
                  select student_id from booksetboughtbystudents(B.bookno))
          or exists(select student_id from booksetboughtbystudents(B.bookno)
                  except
                  select student_id from booksetboughtbystudents(A.bookno)));


--Connect to default database
\c postgres;

--Drop database which you created
DROP DATABASE assignment5;