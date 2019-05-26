create database assignment3;


\c assignment3;

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

create table unary(x integer);
insert into unary values(1), (2), (3);
insert into unary values(4), (5), (6);
table unary;


\qecho 'Q. 1'
select A.x           as x,
       sqrt(A.x)     as square_root_x,
       (A.x * A.x)   as x_squared,
       power(2, A.x) as two_to_the_power_x,
       x !           as factorial_x,
       ln(A.x)       as logarithm_x
from unary A;


\qecho 'Q. 2'
create table A(x integer);
create table B(x integer);
create table C(x integer);
insert into A
values (1),
       (2),
       (3),
       (4),
       (5);

insert into B
values (1),
       (6),
       (7),
       (4),
       (5);

insert into C
values (4),
       (5);

\qecho 'Q. 2 a (1) '
select not exists (select t1.x from A t1 intersect select t2.x from B t2) as answer;


\qecho 'Q. 2 a (2)'
select not exists(select t1.x from A t1, B t2 where t1.x = t2.x) as answer;


\qecho 'Q. 2 b (1)'
select exists((select * from A
                   union select * from B) except (select * from B)) and exists((select * from B
                                                                                    union select * from A) except (
                                                                                                                  select *
                                                                                                                  from A)) as answer;


\qecho 'Q. 2 b (2)'
select exists(select t1.x from A t1 where t1.x not in (select t2.x from B t2)) and
       exists(select t2.x from B t2 where t2.x not in (select t1.x from A t1)) as answer;

;

\qecho 'Q. 2 c(1)'
select not exists(((select t1.x from C t1 where t1.x in (select x from A intersect select x from B)) except select x from C)) as answer;

\qecho 'Q. 2 c(2)'
select not exists (select t1.x from C t1 where t1.x in (select t1.x from A t1 where t1.x in (select x from B))except select x from C) as answer;





\qecho 'Q.3'
create table Point(pid integer, x float, y float);
insert into Point
values (1, 0, 0),
       (2, 0, 1),
       (3, 1, 0),
       (4, 0, 2),
       (5, 2, 2);

create FUNCTION distance(x1 float, y1 float, x2 float, y2 float)
  RETURNS float as
$$
select sqrt(power(x1-x2, 2) + power(y1-y2, 2))
$$ LANGUAGE  SQL;


with distances as (select A.pid as point_1, B.pid as point_2, distance(A.x, A.y, B.x, B.y) as squared
from Point A,
     Point B
where A.pid != B.pid) select distinct point_1, point_2 from distances  A where A.squared <= ALL(select distinct B.squared from distances B);


\qecho 'Q4'
create table P(coefficient integer, degree integer);
create table Q(coefficient integer, degree integer);
insert into P values(2, 2), (-5, 1), (5, 0);
insert into Q values(3, 3), (1, 2), (-1, 1);

create view multiplication as (select A.coefficient * B.coefficient as newCoefficient,
                                        A.degree + B.degree           as newDegree
                        from P A,
                             Q B order by newDegree desc);


create FUNCTION returnVariable(comparisonDegree integer)
  returns bigint  as
$$
select sum(newCoefficient) from multiplication where newDegree = comparisonDegree
$$ LANGUAGE SQL;

select distinct returnVariable(A.newDegree) as coefficient, A.newDegree as degree  from multiplication A order by A.newDegree desc;


\qecho 'Q. 5'

--5
create table matrix_1(row int, colmn int, value int);
insert into matrix_1 values(1,1,1), (1,2,2), (1,3,3), (2,1,1), (2,2,-10), (2,3,5), (3,1,4), (3,2,0), (3,3,-2);
create table matrix_2(row int, colmn int, value int);
insert into matrix_2 values(1,1,2), (1,2,3), (1,3,-3), (2,1,0), (2,2,0), (2,3,0), (3,1,-1), (3,2,5), (3,3,2);

create function returnResult(rowNumber integer, colNumber integer )
  returns bigint as
  $$
with mat2 as (select distinct B.row, B.colmn, B.value
              from matrix_1 A,
                   matrix_2 B
              where B.colmn = colNumber
                and A.row = 1
              order by B.row),
     mat1 as (select distinct A.row, A.colmn, A.value
              from matrix_1 A,
                   matrix_2 B
              where B.colmn = 1
                and A.row = rowNumber
              order by A.colmn)
select SUM(A.value * B.value) as mul
from mat1 A,
     mat2 B
where A.colmn = B.row;
  $$ LANGUAGE SQL;

select distinct A.row, A.colmn, returnResult(A.row, A.colmn) from matrix_1 A order by row;


\qecho 'Q. 6. a'
-- 6.a
create FUNCTION booksBoughtbyStudent(student_id integer)
  returns table(bookno int, title text, price int) as
$$
select distinct A.bookno, A.title, A.price from book A, buys B where B.sid = student_id and B.bookno = A.bookno
$$ LANGUAGE SQL;

create FUNCTION countPerStudent(student_id integer)
  returns bigint as
$$
with countTable as (select * from booksBoughtbyStudent(student_id))
select count(bookno)
from countTable where countTable.price > 40;
$$ LANGUAGE SQL;

select distinct A.sid, countPerStudent(A.sid) from  student A ;

\qecho 'Q. 6. b'
-- 6.b
create function bookpriceSummation(student_id integer)
  returns bigint as
  $$
    select SUM(Price) from booksBoughtbyStudent(student_id);
  $$ LANGUAGE SQL;


with studentBooks as (select A.sid, A.sname, bookpriceSummation(A.sid) as priceSummation from student A)
select distinct A.sid, A.sname
from studentBooks A
where A.sid in (select sid from buys) and A.priceSummation in (select max(priceSummation) from studentBooks);

\qecho 'Q. 6. c'
--6 c
create function returnLowestPricedBook(student_id integer)
  returns table(bookno integer) as
  $$
  select A.bookno from booksBoughtbyStudent(student_id) A where A.price in (select min(price) from booksBoughtbyStudent(student_id))
$$ lANGUAGE SQL;

select distinct A.sid, B.bookno, B.title
from student A,
     book B,
     buys D,
     returnLowestPricedBook(A.sid) C
where A.sid = D.sid
and (D.sid,B.bookno) in (select sid,bookno from buys)
and C.bookno = B.bookno;

\qecho 'Q. 6. d'
--6 d
create function returnBookCount(student_id integer)
  returns bigint as
  $$
    select count(distinct bookno) from booksBoughtbyStudent(student_id)
  $$ LANGUAGE SQL;

select A.sid, B.sid from student A, student B where returnBookCount(A.sid) = returnBookCount(B.sid) and A.sid != B.sid;

\qecho 'Q. 7'
--7
with studentsWhoBoughtBooks as (select A.sid from student A where A.sid in (select distinct A.sid from buys A)),
     booksBoughtOver60 as (select distinct A.sid
                           from buys A
                           where A.bookno in (select bookno from book where price > 60))
select A.sid, A.sname
from student A
where not exists(select B.sid from studentsWhoBoughtBooks B where B.sid = A.sid intersect select sid from booksBoughtOver60);

\qecho 'Q. 8'
--8


with studentsWhoMajorInCSandMath as (select A.sid, A.sname
                                     from student A,
                                          major B
                                     where A.sid = B.sid
                                       and B.major = 'CS'
    intersect
    select A.sid, A.sname
    from student A,
         major B
    where A.sid = B.sid
      and B.major = 'Math'),BooksBoughtByStudentsmajoring as (
select  A.bookno, A.title
from book A,
     studentsWhoMajorInCSandMath B,
     buys C
where B.sid = C.sid and C.bookno = A.bookno group by A.bookno having count(A.bookno) in (select count(distinct sid) from studentsWhoMajorInCSandMath )),
AllTheBooksBought as (select distinct A.bookno from buys A)
select A.bookno, A.title from book A where exists (select Y.bookno from BooksBoughtByStudentsmajoring Y where A.bookno = Y.bookno
                                               intersect
                                               select Z.bookno from AllTheBooksBought Z where A.bookno = Z.bookno);





\qecho 'Q. 9'
--9
with AllBooksBought as (select distinct A.bookno, A.sid from buys A),
     BookWithLowestPrice as (select A.bookno from book A where A.price in (select min(price) from book))
select distinct A.sid, A.sname
from student A,
     buys B
where A.sid = B.sid
  and exists(select bookno from AllBooksBought c where A.sid = C.sid  intersect select bookno from BookWithLowestPrice);

\qecho 'Q. 10'
--10
select A.sid, B.sid
from student A,
     student B
where exists(select C.bookno
             from booksBoughtbyStudent(A.sid) C
          except
                 select D.bookno from booksBoughtbyStudent(B.sid) D);

\qecho 'Q. 11'
--11
create function returnStudentsWhoBoughtBook(book_no integer)
  returns table(sid integer) as $$
    select distinct A.sid from buys A where A.bookno = book_no
  $$
lANGUAGE SQL;

create function returnCSStudentsWhoBoughtBook(book_no integer)
  returns table(sid integer) as $$
    select distinct A.sid from buys A, major B where A.bookno = book_no and A.sid in(select distinct A.sid from major  A where A.major = 'CS')
  $$
lANGUAGE SQL;

select A.bookno, A.title
from book A
where (select count(1) from (select returnStudentsWhoBoughtBook(A.bookno)
                            intersect
                            select returnCSStudentsWhoBoughtBook(A.bookno)) Q) > 2;


\qecho 'Q. 12'
--12
select distinct A.sid, A.sname from student A where (select count(1) from (select distinct bookno from book where price > 35
                                                                          intersect
                                                                          select bookno from booksBoughtbyStudent(A.sid)) Q) % 2 != 0;


\qecho 'Q. 13'
--13
create function allbut3students() returns bigint as $$
  select count(distinct sid) - 3 from student
$$ LANGUAGE SQL;

select distinct A.bookno, A.title
from book A
where (select count(1)
       from (select distinct sid from buys A
             intersect
             select sid from returnstudentswhoboughtbook(A.bookno)) Q) = allbut3students();


\qecho 'Q. 14'
--14
select distinct A.sid, B.sid from student A, student B where ((select count(1) from (select booksBoughtbyStudent(A.sid)
                                                                          intersect
                                                                          select booksBoughtbyStudent(B.sid)) Q) != returnBookCount(A.sid)
                                                        or (select count(1) from (select booksBoughtbyStudent(A.sid)
                                                                          intersect
                                                                          select booksBoughtbyStudent(B.sid)) Q) != returnBookCount(B.sid))
                                                      and A.sid != B.sid;


\qecho 'Q. 15'
--15
SELECT s.sid, s.sname
FROM Student s
WHERE(select count(1)
FROM Book b
WHERE b.title <> 'Networks' AND
(SELECT count(1)
FROM Buys t, Book b1
WHERE t.sid = s.sid AND t.bookno = b1.bookno) >= 1) >=1;

\qecho 'Q. 16'
--16
select b.bookno, b.title from book b where b.price <= (select b.price from (SELECT b1.price
FROM Book b1
WHERE (SELECT count(1)
FROM Buys t, Major m
WHERE t.sid = m.sid and m.major = 'CS' and b1.bookno = t.bookno) = 0) b where not exists(select a.price from (SELECT b1.price
FROM Book b1
WHERE (SELECT count(1)
FROM Buys t, Major m
WHERE t.sid = m.sid and m.major = 'CS' and b1.bookno = t.bookno) = 0) a where a.price < b.price));






--Connect to default database
\c postgres;

--Drop database which you created
DROP DATABASE assignment3;

