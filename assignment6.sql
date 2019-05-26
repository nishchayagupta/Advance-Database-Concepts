-- Creating database with my initials
create database assignment6;

--Connecting database
\c assignment6;


create table cites(bookno int,citedbookno int);
create table book(bookno int, title text, price int);
create table student(sid int, sname text);
create table major(sid int, major text);
create table buys(sid int, bookno int);


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



\qecho 'creating atleast One and All elements function'

create or replace function atleastOne(a anyarray, b anyarray) returns boolean as $$
  select a && b
  $$language sql;

create or replace function allelements(a anyarray, b anyarray) returns boolean as $$
  select a <@ b
  $$language sql;


\qecho '10.a'
--10.a
create or replace function setIntersection(A anyarray, B anyarray) returns anyarray as $$
  with Aset as (select unnest(A)), Bset as (select unnest(B)) select array((select * from Aset) intersect (select * from  Bset))
  $$language sql;

\qecho '10.b'
--10.b
create or replace function setdifference(A anyarray, B anyarray) returns anyarray as $$
  with Aset as (select unnest(A)), Bset as (select unnest(B)) select array((select * from Aset) except (select * from  Bset))
  $$language sql;

\qecho '11.a'
--11. a
create view book_students as(select distinct b.bookno, array(select b1.sid from buys b1 where b1.bookno = b.bookno) as books from buys b);

\qecho '11.b'
--11. b
create view book_citedbooks as (select distinct b.bookno, array(select distinct c.bookno from cites c where c.bookno = b.bookno) as citedbooks from book b);

\qecho '11.c'
--11.c
create view book_citingbooks as (select distinct b.bookno, array(select distinct c.bookno from cites c where c.citedbookno = b.bookno) as citedby from book b);

\qecho '11.d'
--11.d
create view major_students as (select distinct m.major, array(select distinct m1.sid from major m1 where m1.major = m.major) as majoring_students from major m);

\qecho '11.e'
--11.e
create view student_majors as (select distinct s.sid, array(select distinct m.major from major m where m.sid = s.sid)  as students from student s);

\qecho '12.a'
--12.a
select distinct b.bookno
from book b
where atleastOne((select a.citedby from book_citingbooks a where a.bookno = b.bookno),
                 array(select c.bookno from book c where c.price < 50));

\qecho '12.b'
--12.b
select s.sid from student s where '{"CS", "Math"}' <@ (select a.students from student_majors a where a.sid = s.sid);

\qecho '12.c'
--12.c
select b.bookno from book b where cardinality((select a.citedby from book_citingbooks a where a.bookno = b.bookno)) = 1;

\qecho '12.d'
--12.d
select s.sid
from student s
where (array(select b.bookno from book b where b.price > 50) <@
       array(select distinct c.bookno from book_students c where array[s.sid] <@ c.books));

\qecho '12.e'
--12.e
select s.sid
from student s
where not (atleastOne(array(select distinct c.bookno from book_students c where array [s.sid] <@ c.books),
                      array(select a.bookno from book a where a.price > 50)));

\qecho '12.f'
--12.f
select s.sid
from student s
where not (atleastOne(array(select distinct c.bookno from book_students c where array [s.sid] <@ c.books),
                      array(select a.bookno from book a where a.price <= 50)))
  and array(select distinct c.bookno from book_students c where array [s.sid] <@ c.books) <> '{}';

\qecho '12.g'
--12.g
select s.sid
from student s
where array ['CS'] <@ (select a.students from student_majors a where a.sid = s.sid)
  and not (atleastOne(array(select distinct c.bookno from book_students c where array [s.sid] <@ c.books),
                      array(select b.bookno
                            from book_students b
                            where atleastone(array(select s.sid
                                                   from student s
                                                   where array ['Math'] <@
                                                         (select a.students from student_majors a where a.sid = s.sid)),
                                             (select a.books from book_students a where b.bookno = a.bookno)))));

\qecho '12.h'
--12.h
select distinct s.sid, b.bookno
from student s,
     book b
where atleastone(array(select distinct c.bookno from book_students c where array [s.sid] <@ c.books),
                 (select b2.citedby from book_citingbooks b2 where b2.bookno = b.bookno));

\qecho '12.i'
--12.i
select distinct s.sid, b.bookno
from student s,
     book b
where (array(select distinct c.bookno from book_students c where array [s.sid] <@ c.books) <@
       (select b2.citedby from book_citingbooks b2 where b2.bookno = b.bookno))
and array(select distinct c.bookno from book_students c where array [s.sid] <@ c.books) <> '{}';

\qecho '12.j'
--12.j
select s1.sid, s2.sid
from student s1,
     student s2
where ((array(select distinct c.bookno from book_students c where array [s1.sid] <@ c.books) <@
        array(select distinct c.bookno from book_students c where array [s2.sid] <@ c.books)) and
       (array(select distinct c.bookno from book_students c where array [s2.sid] <@ c.books) <@
        array(select distinct c.bookno from book_students c where array [s1.sid] <@ c.books)))
and s1.sid != s2.sid and array(select distinct c.bookno from book_students c where array [s1.sid] <@ c.books) <> '{}';

\qecho '12.k'
--12.k
select s1.sid, s2.sid
from student s1,
     student s2
where (cardinality(array(select distinct c.bookno from book_students c where array [s1.sid] <@ c.books)) =
       cardinality(array(select distinct c.bookno from book_students c where array [s2.sid] <@ c.books))) and s1.sid <> s2.sid
and array(select distinct c.bookno from book_students c where array [s1.sid] <@ c.books) <> '{}';

\qecho '12.l'
--12.l
select b.bookno
from book b
where (cardinality((select a.citedbooks from book_citedbooks a where a.bookno = b.bookno)) =
       ((select (select count(bookno) from book) - 3)));


\c postgres;

--Drop database which you created
DROP DATABASE assignment6;

