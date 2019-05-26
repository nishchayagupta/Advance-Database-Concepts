-- Creating database with assignment Number
create database assignment7;

--Connecting database
\c assignment7;

-- 1.a
\qecho 'q.1a';
create table R(a int, b int);
insert into R values(1,2),(1,4),(4,6),(2,9),(3,8),(4,1),(7,9),(4,6),(12,22),(11,1),(7,12),(3,4),(5,7),(9,9);

create or replace function mapper(InputKey int, InputValue int) returns table(OutputKey int, OutputValue int) as $$
  select InputKey, InputKey;
  $$ language sql;

create or replace function reducer(InputKey int, InputValue int[]) returns table(OutputKey int, OutputValue int) as $$
  select InputKey, InputKey;
  $$ language sql;

-- Testing MapReduce
with Mapping as (
  select m.outputkey, m.outputValue
  from R r,
       LATERAL (select a.outputkey, a.outputValue from mapper(r.a, r.b) a ) m),
     grouping as (
       select distinct m.outputkey, (select array(select a.outputValue from Mapping a where a.outputkey = m.outputkey)) as array_val
       from Mapping m),
     reducing as (select z.outputKey
                  from grouping g,
                       LATERAL(select r.OutputKey, r.OutputValue from reducer(g.OutputKey, g.array_val) r) z)
select r.outputkey
from reducing r;


drop function mapper(InputKey int, InputValue int);
drop function reducer(InputKey int, InputValue int[]);
drop table R;


\qecho 'q.1b I have used the code 0 for table R and code 1 for table S to remove redundancy of mappers from part d as there are 3 tables.I would follow the 0 and 1 rule throughout the first question';

create table R(a int);
create table S(a int);
insert into R values(1),(1),(4),(2),(3),(4),(7),(4),(12),(11),(7),(3),(5),(9);
insert into S values(2),(4),(6),(9),(8),(1),(9),(6),(122),(11),(12),(4),(7),(9);


create or replace function mapper(InputKey int, InputValue int) returns table(OutputKey int, OutputValue int) as $$
  select InputKey, InputValue;
  $$ language sql;

create or replace function reducer(InputKey int, InputValue int[]) returns table(OutputKey int, OutputValue int) as $$
  select InputKey, unnest(InputValue) as table_val where array [0] <@ InputValue and InputValue <@ array [0];
  $$ language sql;

with mapping as (select d.OutputKey, 0 as table_val
                 from R r,
                      LATERAL (select h.outputkey, h.outputvalue from mapper(r.a, 0) h) d
                 union
                 select d.OutputKey, 1 as table_val
                 from S s,
                      LATERAL (select h.outputkey, h.outputvalue from mapper(s.a, 1) h) d),

     grouping as (select m.OutputKey, (select array(select table_val from mapping z where z.OutputKey = m.OutputKey)) as table_vals
                  from mapping m),
     reducing as (select y.OutputKey
                  from grouping g,
                       LATERAL (select f.OutputKey, f.OutputValue from reducer(g.OutputKey, g.table_vals) f) y)
select r.outputKey
from reducing r;

drop table R;
drop table S;
drop function mapper(InputKey int, InputValue int);
drop function reducer(InputKey int, InputValue int[]);


\qecho 'q.1c I have used the code 0 for table R and code 1 for table S to remove redundancy of mappers from part d as there are 3 tables.I would follow the 0 and 1 rule throughout the first question';

create table R(a int, b int);
create table S(b int, c int);
insert into R values(1,2),(1,4),(4,6),(2,9),(3,8),(4,1),(7,9),(4,6),(12,22),(11,1),(7,12),(3,4),(5,7),(9,9);
insert into S values(1,2),(1,4),(4,6),(2,9),(3,8),(4,1),(7,9),(4,6),(12,22),(11,1),(7,12),(3,4),(5,7),(9,9);

CREATE OR REPLACE FUNCTION unnest_2d_1d(anyarray)
  RETURNS SETOF anyarray AS
$func$
SELECT array_agg($1[d1][d2])
FROM   generate_subscripts($1,1) d1
    ,  generate_subscripts($1,2) d2
GROUP  BY d1
ORDER  BY d1
$func$  LANGUAGE sql;

create or replace function mapper(first_val int, second_val int) returns table(outputKey int , OutputValue int) as $$
  select first_val, second_val;
  $$ language sql;

create or replace function reducer(key_value int, value_group int[]) returns table (value_a int, value_c int) as $$
  with a_b as (
  select key_value, unnest_2d_1d(value_group) as array_val)
  select a.a, b.c
from (select array_val[2] as a, key_value from a_b where array_val[1] = 0) a,
     (select array_val[2] as c, key_value from a_b where array_val[1] = 1) b where a.key_value = b.key_value;
$$ language sql;


with mapping as (select z.OutputValue as b, array[0, z.OutputKey] as table_pair
                 from R r,
                      LATERAL (select m.OutputKey, m.OutputValue from mapper(r.a, r.b) m) z
                 union
                 select z.OutputKey as b, array [1, z.OutputValue] as table_pair
                 from S s,
                      LATERAL (select m.OutputKey, m.OutputValue from mapper(s.b, s.c) m) z),
      grouping as (select distinct m.b, (select array(select q.table_pair from mapping q where q.b = m.b)) as group_val
                  from mapping m),
      reducing as (select z.value_a as a, g.b, z.value_c as c from grouping g, LATERAL(select value_a, value_c from reducer(g.b, g.group_val)) z)
      select r.a, r.b, r.c from reducing r;

drop function unnest_2d_1d(anyarray);
drop table R;
drop table S;
drop function mapper(first_val int, second_val int);
drop function reducer(InputKey int, InputValue int[]);


-- 1.d
\qecho 'q.1d I have used the code 0 and code 1 to distinguish between tables to remove redundancy of mappers from part d as there are 3 tables.I would follow the 0 and 1 rule throughout the first question';

create table R( a int );
create table S( a int );
create table T( a int );

insert into R values (1), (2), (5), (8), (3), (11), (7), (9), (10), (12), (14);
insert into S values (1), (2), (4), (11), (12), (5), (2), (8), (23), (17), (18);
insert into T values (4), (7), (12), (23), (4), (2), (9), (81), (5), (9), (13);

create or replace function mapper(InputKey int, InputValue int) returns table(OutputKey int, OutputValue int) as $$
  select InputKey, InputValue;
  $$ language sql;

create or replace function reducer(InputKey int, InputValue int[]) returns table(OutputKey int, OutputValue int) as $$
  select InputKey, unnest(InputValue) as table_val where array [0] <@ InputValue and InputValue <@ array [0];
  $$ language sql;

create or replace function mapper1(InputKey int, InputValue int) returns table(OutputKey int, OutputValue int) as $$
  select InputKey, InputValue;
  $$ language sql;

create or replace function reducer1(InputKey int, InputValue int[]) returns table(OutputKey int, OutputValue int) as $$
  select InputKey, InputKey;
  $$ language sql;


with r_except_s as (with mapping as (select d.OutputKey, 0 as table_val
                                     from R r,
                                          LATERAL (select h.outputkey, h.outputvalue from mapper(r.a, 0) h) d
                                     union
                                     select d.OutputKey, 1 as table_val
                                     from S s,
                                          LATERAL (select h.outputkey, h.outputvalue from mapper(s.a, 1) h) d),

                         grouping as (select m.OutputKey,
                                             (select array(select table_val from mapping z where z.OutputKey = m.OutputKey)) as table_vals
                                      from mapping m),
                         reducing as (select y.OutputKey
                                      from grouping g,
                                           LATERAL (select f.OutputKey, f.OutputValue
                                                    from reducer(g.OutputKey, g.table_vals) f) y)
                    select r.outputKey
                    from reducing r),
     t_except_r as (with mapping as (select d.OutputKey, 0 as table_val
                                     from T t,
                                          LATERAL (select h.outputkey, h.outputvalue from mapper(t.a, 0) h) d
                                     union
                                     select d.OutputKey, 1 as table_val
                                     from R r,
                                          LATERAL (select h.outputkey, h.outputvalue from mapper(r.a, 1) h) d),

                         grouping as (select m.OutputKey,
                                             (select array(select table_val from mapping z where z.OutputKey = m.OutputKey)) as table_vals
                                      from mapping m),
                         reducing as (select y.OutputKey
                                      from grouping g,
                                           LATERAL (select f.OutputKey, f.OutputValue
                                                    from reducer(g.OutputKey, g.table_vals) f) y)
                    select r.outputKey
                    from reducing r),
     mapping2 as (select unnest(array [z.outputKey, z.OutputValue]) as val_tuple, 1 as one
                  from r_except_s,
                       t_except_r,
                       LATERAL (select outputKey, OutputValue
                                from mapper1(r_except_s.OutputKey, t_except_r.OutputKey)) z),
     grouping2 as (select val_tuple, array_agg(one) as count_occurence from mapping2 group by val_tuple),
     reducing2 as (select z.OutputKey, z.OutputValue
                   from grouping2 g,
                        LATERAL (select OutputKey, OutputValue from reducer1(g.val_tuple, g.count_occurence)) z)
select r.outputKey
from reducing2 r;


drop function mapper(first_val int, second_val int);
drop function reducer(InputKey int, InputValue int[]);
drop function mapper1(InputKey int, InputValue int);
drop function reducer1(InputKey int, InputValue int[]);
drop table R;
drop table S;
drop table T;



\qecho 'q.2a';
create table R(K int, V int);
create table S(K int, W int);
insert into R values(1,1), (1, 2), (2, 1), (3, 3);
insert into S values(1, 1),(1,3),(3, 2),(4, 1),(4, 4);

\qecho 'q.2a type creation';

create type cogroupVariable as (R_value int[] , S_value int[]);

\qecho 'q.2a cogroup view definition';

create view cogroup as (
WITH Kvalues AS (SELECT r.K FROM R r UNION SELECT s.K FROM S s),
     R_K AS (SELECT r.K, ARRAY_AGG(r.V) AS R_value FROM R r GROUP BY (r.K) UNION SELECT k.K, '{}' AS R_value
             FROM Kvalues k WHERE k.K NOT IN (SELECT r.K FROM R r)),
     S_K AS (SELECT s.K, ARRAY_AGG(s.W) AS S_value FROM S s GROUP BY (s.K) UNION SELECT k.K, '{}' AS S_value
             FROM Kvalues k WHERE k.K NOT IN (SELECT s.K FROM S s))
SELECT K, (R_value, S_value) :: cogroupVariable
FROM R_K
       NATURAL JOIN S_K);
select * from cogroup;


\qecho 'q.2b Function definition for Natural Join';

create or replace function R_NaturalJoin_S() returns table(K_output int, V_output int, W_output int) as $$
with relevantValues as (select k, ((row)::cogroupVariable).r_value as rVal, ((row)::cogroupVariable).s_value as sVal
                        from cogroup
                        where ((row)::cogroupVariable).r_value <> '{}'
                          and ((row)::cogroupVariable).s_value <> '{}'),
     r_records as (select k, unnest(rVal) as rValue from relevantValues),
     s_records as (select k, unnest(sVal) as sValue from relevantValues)
select distinct a.k, a.rValue, b.sValue
from r_records a,
     s_records b
where a.k = b.k;
$$ language sql;
select * from R_NaturalJoin_S();

\qecho 'q.2c function definition for R anti-join S';
create or replace function R_antijoin_S() returns table (K_value int, V_value int) as $$
with R_values as (
  select k, unnest(((row)::cogroupVariable).r_value) as V_values from cogroup),
     S_values as (
       select k, unnest(((row)::cogroupVariable).s_value) as W_values from cogroup)
select distinct a.k, a.V_values
from R_values a,
     S_values b
where a.k not in (select K from S_values);
  $$ language sql;
select * from R_antijoin_S();

drop function R_antijoin_S();
drop function R_NaturalJoin_S();
drop view cogroup cascade ;
drop type cogroupVariable;
drop table R cascade ;
drop table S cascade ;

------------------------------------------------------------------------------------------------------------------------------------

\qecho 'q.3 setup of cogroup variable';
create table A( a int );
create table B( a int );
insert into A values(1), (2), (3), (4), (5);
insert into B values(1), (3), (6);

create type CogroupUnaryVariable  as (a_value int[], b_value int[]);

\qecho 'q.3 cogroup output';
create view cogroup as (with grouping_A as (select a as a_val, a as a_val1 from A),
     grouping_B as (select a as b_val, a as b_val1 from B),
     allValues as (select q1.a from A q1 union select q1.a from B q1),
     A_a_val as (SELECT a.a_val, ARRAY_AGG(a.a_val1) AS Aa_value
                 FROM grouping_A a
                 GROUP BY (a.a_val)
                 UNION
                 SELECT k.a, '{}' AS Aa_value
                 FROM allValues k
                 WHERE k.a NOT IN (SELECT r.a_val FROM grouping_A r)),
     B_a_val as (SELECT b.b_val, ARRAY_AGG(b.b_val1) AS Ba_value
                 FROM grouping_B b
                 GROUP BY (b.b_val)
                 UNION
                 SELECT k.a, '{}' AS Ba_value
                 FROM allValues k
                 WHERE k.a NOT IN (SELECT r.b_val FROM grouping_B r))
select z.a, (aa_value, ba_value)::CogroupUnaryVariable
from allValues z,
     A_a_val a
       natural join B_a_val b
where z.a = a.a_val and z.a = b.b_val);
select * from cogroup;

\qecho 'q.3a';
create or replace function A_intersect_B() returns table(a_value int) as $$
select a
from cogroup
where ((row)::CogroupUnaryVariable).a_value <> '{}'
  and ((row)::CogroupUnaryVariable).b_value <> '{}';
  $$ language sql;
select * from A_intersect_B();


\qecho 'q.3b';
\qecho 'q.3b (a except b)';

create or replace function A_except_B() returns table(a_value int) as $$
select a
from cogroup
where ((row)::CogroupUnaryVariable).a_value <> '{}'
  and ((row)::CogroupUnaryVariable).b_value = '{}';

  $$ language sql;
select * from A_except_B();

\qecho 'q.3b (b except a)';
create or replace function B_except_A() returns table(a_value int) as $$
select a
from cogroup
where ((row)::CogroupUnaryVariable).a_value = '{}'
  and ((row)::CogroupUnaryVariable).b_value <> '{}';

  $$ language sql;

drop view if exists cogroup cascade;
drop table if exists A cascade;
drop table if exists B cascade;
drop type if exists CogroupUnaryVariable;
drop function if exists A_intersect_B();
drop function if exists A_except_B();
drop function if exists B_except_A();



--------------------------------------------------------------------------------------------------------------------------
-- Nested
\qecho 'q.4a setup tables and insert data into tables';

create table enroll(sid text, cno text, grade text);

insert into enroll values('s100','c200', 'A'),('s100','c201', 'B'),('s100','c202', 'A'),('s101','c200', 'B'),('s101','c201', 'A'),('s102','c200', 'B'),('s103','c201', 'A'),('s101','c202', 'A'),('s101','c301', 'C'),('s101','c302', 'A'),('s102','c202', 'A'),('s102','c301', 'B'),('s102','c302', 'A'),('s104','c201', 'D');

create table course(cno text, cname text, dept text);

insert into course values('c200', 'PL', 'CS'), ('c201', 'Calculus', 'Math'), ('c202', 'Dbs', 'CS'), ('c301', 'AI', 'CS'), ('c302', 'Logic', 'Philosophy');

create table student(sid text,  sname  text,   major  text,  byear int);

insert into student
values ('s100', 'Eric', 'CS', 1987),
       ('s101', 'Nick', 'Math', 1990),
       ('s102', 'Chris', 'Biology', 1976),
       ('s103', 'Dinska', 'CS', 1977),
       ('s104', 'Zanna', 'Math', 2000);

CREATE TABLE major (sid text, major text);
INSERT INTO major
VALUES ('s100', 'French'),
       ('s100', 'Theater'),
       ('s100', 'CS'),
       ('s102', 'CS'),
       ('s103', 'CS'),
       ('s103', 'French'),
       ('s104', 'Dance'),
       ('s105', 'CS');

create type studentType as (sid text);
create type courseType as (cno text);

CREATE TYPE gradeCoursesType AS (grade text, courses courseType[]);
CREATE TABLE studentGrades(sid text, gradeInfo gradeCoursesType[]);

CREATE TYPE gradeStudentsType AS (grade text, student studentType[]);
CREATE TABLE courseGrades(cno text, gradeInfo gradeStudentsType[]);

--4.a
\qecho 'q.4a';

insert into courseGrades
with e as (select cno, grade, array_agg(row (sid)::studentType) as students from enroll group by (cno, grade)),
     f as (select cno, array_agg(row (grade, students)::gradeStudentsType) as gradeInfo from e group by (cno))
select *
from f
order by cno;
table courseGrades;

-- 4.b
\qecho 'q.4b';

with CourseGradeOpened as (select sg.cno as course_no, g.grade as grade, c.sid as student_id
                           from courseGrades sg,
                                unnest(sg.gradeInfo) g,
                                unnest(g.student) c)
insert
into studentGrades
with e as (select student_id, grade, array_agg(row (course_no)::courseType) as courses
           from CourseGradeOpened
           group by (student_id, grade)),
     f as (select student_id, array_agg(row (grade, courses)::gradeCoursesType) as gradeInfo
           from e
           group by (student_id))
select *
from f
order by student_id;

table studentGrades;


--4.c
\qecho 'q.4c';

create table jcourseGrades(courseinfo jsonb);
insert into jcourseGrades
with e as (select cno,
                  grade,
                  array_to_json(array_agg(json_build_object('sid',
                                                            sid))) as students
           from enroll
           group by (cno, grade)
           order by 1),
     f as (select json_build_object(
                      'cno', cno,
                      'gradeInfo',
                      array_to_json(
                          array_agg(
                              json_build_object(
                                  'grade', grade,
                                  'students',
                                  students)))) as gradeInfo
           from e
           group by (cno))
select gradeInfo
from f;
table jcourseGrades;


--4.d
\qecho 'q.4d';

create table jstudentgrades(studentInfo jsonb);

insert into jstudentgrades
with jcoursegradesopened as (
  select distinct cg.courseinfo -> 'cno' as cno, g -> 'grade' as grade, s -> 'sid' as sid
  from jcourseGrades cg,
       jsonb_array_elements(cg.courseinfo -> 'gradeInfo') g,
       jsonb_array_elements(g -> 'students') s),
     e as (select sid,
                  grade,
                  array_to_json(array_agg(json_build_object('cno',
                                                            cno))) as courses
           from enroll
           group by (sid, grade)
           order by 1),
     f as (select json_build_object(
                      'sid', sid,
                      'gradeInfo',
                      array_to_json(
                          array_agg(
                              json_build_object(
                                  'grade', grade,
                                  'courses',
                                  courses)))) as gradeInfo
           from e
           group by (sid)) select  * from f;

table jstudentgrades;

--4.e
\qecho 'q.4e';
insert into studentGrades
with e as (select sid, grade, array_agg(row (cno)::courseType) as courses from enroll group by (sid, grade)),
f as (select sid, array_agg(row(grade, courses)::gradeCoursesType) as gradeInfo from e group by (sid))select * from f order by sid;

insert into courseGrades
with e as (select cno, grade, array_agg(row (sid)::studentType) as students from enroll group by (cno, grade)),
     f as (select cno, array_agg(row (grade, students)::gradeStudentsType) as gradeInfo from e group by (cno))
select *
from f
order by cno;

with E as (select sg.studentInfo ->> 'sid' as sid, c ->> 'cno' as cno
           from jstudentgrades sg,
                jsonb_array_elements(sg.studentInfo -> 'gradeInfo') g,
                jsonb_array_elements(g -> 'courses') c),
     F as (select e.sid                                                                       as sid,
                  s.sname                                                                     as sname,
                  c.dept                                                                      as dept,
                  array_to_json(array_agg(json_build_object('cno', e.cno, 'cname', c.cname))) as courseinfo
           from student s
                  join E e on (s.sid = e.sid)
                  join course c on (e.cno = c.cno)
           group by (e.sid, dept, s.sname)),
     G as (select json_build_object('sid', f.sid, 'sname', f.sname, 'departmentInfo',
                                    array_to_json(
                                        array_agg(json_build_object('dept', f.dept, 'courseInfo', f.courseinfo))))
           from F
           group by (f.sid, f.sname))
select *
from G;

drop table enroll;
drop table course;
drop table student;
drop table major;
drop table studentGrades cascade;
drop table courseGrades cascade;
drop type gradeCoursesType cascade;
drop type gradeStudentsType cascade;
drop type studentType cascade;
drop type courseType cascade;
drop table jcourseGrades;
drop table jstudentgrades;


\c postgres;

--Drop database which you created
DROP DATABASE assignment7;
