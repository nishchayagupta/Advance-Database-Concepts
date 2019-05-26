-- Creating database with my initials
create database assignment4;

--Connecting database
\c assignment4;


--Table creation
create table Student (
  sid   int,
  sname text,
  major text
);



create table Course (
  cno   int,
  cname text,
  total int,
  max   int
);

create table HasTaken (
  sid int,
  cno int
);

create table Enroll (
  sid int,
  cno int
);

create table Waitlist (
  sid      int,
  cno      int,
  position int
);

create table Prerequisite (
  cno    int,
  prereq int
);




\qecho 'Q. 1 Insert triggers'

\qecho 'Student primary key ensured'
create or replace function Student_primary_key()
  returns trigger as
$$
begin
  if NEW.sid in (select distinct sid from student)
  then
    raise exception 'Sid already exists';
  end if;
  return NEW;
end;
$$
language 'plpgsql';


create trigger Student_primary_key_def
  before insert
  on Student
  for each row
execute procedure Student_primary_key();







\qecho 'Course Primary Key ensured'
create or replace function Course_primary_key()
  returns trigger as
$$
begin
  if NEW.cno in (select distinct cno from Course)
  then
    raise exception 'Course already exists';
  end if;
  return new;
end;
$$
language 'plpgsql';


create trigger Course_primary_key_def
  before insert
  on Course
  for each row
execute procedure Course_primary_key();


\qecho 'Insert into prerequisite'
create or replace function ensure_prerequisite_foreign_key()
  returns trigger as
$$
BEGIN
  if ((new.cno in (select cno from course)) and (new.prereq in (select cno from course)))
  then
    return new;
  else if new.cno not in (select cno from course)
  then
    raise exception 'cno not present in Course relation';
  else
    raise exception 'prereq not present in Course Relation';
  end if;
  end if;
END;
$$
language 'plpgsql';


create trigger ensure_prerequisite_foreign_key_def
  before insert
  on Prerequisite
  for each row execute procedure ensure_prerequisite_foreign_key();








\qecho 'Insert into hasTaken Relation'
create or replace function hasTaken_foreign_key()
  returns trigger as
$$
BEGIN
  if ((new.sid in (select sid from student)) and (new.cno in (select cno from course)))
  then
    return new;
  else if (new.sid not in (select sid from student))
  then
    raise exception 'Student Id not present in student relation';
  else
    raise exception 'Couse no not present in Course relation';
  end if;

  end if;
END;
$$
language 'plpgsql';


create trigger hasTaken_foreign_key_def
  before insert
  on HasTaken
  for each row execute procedure hasTaken_foreign_key();










\qecho 'Enroll foreign key condition'
create or replace function enroll_foreign_key()
  returns trigger as
$$
BEGIN
  if ((new.sid in (select sid from student)) and (new.cno in (select cno from course)))
  then
    return new;
  else if (new.sid not in (select sid from student))
  then
    raise exception 'Student Id not present in student relation';
  else
    raise exception 'Couse no not present in Course relation';
  end if;

  end if;
END;
$$
language 'plpgsql';


create trigger enroll_foreign_key_def
  before insert
  on enroll
  for each row execute procedure enroll_foreign_key();












\qecho 'Waitlist relation foreign key definition'
create or replace function waitlist_foreign_key()
  returns trigger as
$$
BEGIN
  if ((new.sid in (select sid from student)) and (new.cno in (select cno from course)))
  then
    return new;
  else if (new.sid not in (select sid from student))
  then
    raise exception 'Student Id not present in student relation';
  else
    raise exception 'Couse no not present in Course relation';
  end if;

  end if;
END;
$$
language 'plpgsql';


create trigger waitlist_foreign_key_def
  before insert
  on waitlist
  for each row execute procedure waitlist_foreign_key();










\qecho 'Delete Triggers'
\qecho 'Student Table delete primary key logic.I have implemented the delete triggers as mentioned on Piazza by using NULL.'
create or replace function student_delete_primary_key()
  returns trigger as
$$
begin
  if (old.sid in (select distinct sid from waitlist))
  then
    delete from Waitlist where sid = old.sid;
  end if;
  if (old.sid in (select distinct sid from enroll))
  then
    delete from enroll where sid = old.sid;
  end if;
  return OLD;
end;
$$
language 'plpgsql';


create trigger student_delete_primary_key_def
  before delete
  on Student
  for each row
execute procedure student_delete_primary_key();











\qecho 'Course table delete trigger'
create or replace function course_delete_primary_key()
  returns trigger as
$$
begin
  if (old.cno in (select distinct cno from waitlist))
  then
    delete from waitlist where cno = old.cno;
  end if;
  if (old.cno in (select distinct cno from prerequisite))
  then
    delete from Prerequisite where cno = old.cno;
  end if;
  if (old.cno in (select distinct prereq from prerequisite))
  then
    delete from Prerequisite where prereq = old.cno;
  end if;
  return OLD;
end;
$$
language 'plpgsql';


create trigger course_delete_primary_key_def
  before delete
  on Course
  for each row
execute procedure course_delete_primary_key();












\qecho '2 A and B'

\qecho 'This query consists the application of question 3 as well. here Major_with_total table being updated is a view which has its own set of triggers defined in the 3rd answer'
create or replace function update_total_courses()

  returns trigger as
$$
begin
  if exists(select major from major_students where major = (select major from student where sid = new.sid))
  then
    update major_with_total set total = total + 1 where major = (select major from student where sid = new.sid);
  else
    insert into major_with_total values ((select major from student where sid = new.sid), 1);
  end if;
  update course set total = (select count(sid) from enroll where cno = NEW.cno) where cno = NEW.cno;
  return NEW;
end;
$$
language 'plpgsql';


create trigger update_total_courses_def
  after insert
  on enroll
  for each row
execute procedure update_total_courses();


\qecho 'Check if all the prerequisites are met in order to take the course'
create or replace function check_prerequisites_before_enroll()
  returns trigger as
$$
BEGIN
  if exists(select prereq from prerequisite where cno = new.cno
            except
            select cno from hastaken where sid = new.sid)
  then
    raise exception 'All the prerequisites are not met';
  else if (select total from course where cno = new.cno) >= (select max from course where cno = new.cno)
  then
    insert into waitlist values (new.sid, new.cno, (select count(sid) from waitlist where cno = new.cno) + 1);
    return NULL;
  else
    return new;
  end if;
  end if;
END;
$$
language 'plpgsql';


create trigger check_prerequisites_before_enroll_def
  before insert
  on enroll
  for each row
execute procedure check_prerequisites_before_enroll();


\qecho '2.c (Deletion Logic)'
create or replace function delete_from_waitlist_table()
  returns trigger as
$$
begin
  update Waitlist
  set position = position - 1
  where cno = old.cno
    and sid != old.sid
    and position > old.position;
  return old;
end;
$$
language 'plpgsql';


create trigger delete_from_waitlist_table_def
  after delete
  on Waitlist
  for each row
execute procedure delete_from_waitlist_table();


\qecho 'deletion from enroll table which would lead to insertion of highest position person from the waitlist table. This query consists the application of question 3 as well. here Major_with_total table being updated is a view which has its own set of triggers defined in the 3rd answer'
create or replace function delete_from_enroll_table_management()
  returns trigger as
$$
begin
  if ((select total from major_with_total where major = (select major from student where sid = old.sid)) = 1)
  then
    delete from major_with_total where major = (select major from student where sid = old.sid);
  else
    update major_with_total set total = total - 1 where major = (select major from student where sid = old.sid);
  end if;
  update course set total = total - 1 where cno = old.cno;
  if exists(select cno from waitlist where cno = old.cno)
  then
    insert into enroll
    values ((select sid
             from waitlist
             where position = 1
               and cno = old.cno), old.cno);
  end if;
  if exists(select cno from waitlist where cno = old.cno)
  then
    delete
    from Waitlist
    where sid = (select sid
                 from waitlist
                 where position = 1
                   and cno = old.cno)
      and cno = old.cno;
  end if;
  return NULL;
end;
$$
language 'plpgsql';


create trigger delete_from_enroll_table_management_def
  after delete on enroll
  for each row
  execute procedure delete_from_enroll_table_management();











\qecho 'Q. 3 View management using triggers'



create table major_students (
  Major text,
  total int
);

create view major_with_total as (select distinct major, total
                                 from major_students);

create or replace function insert_major_with_total()
  returns trigger as
$$
begin
  if exists(select major from major_students where major = new.major)
  then
    update Major_students set total = new.total where major = new.major;
  else
    insert into Major_students values (new.major, new.total);
  end if;
  return new;
end;
$$
language 'plpgsql';


create trigger insert_major_with_total_def
  instead of insert or update
  on major_with_total
  for each row
execute procedure insert_major_with_total();


create or replace function delete_major_with_total()
  returns trigger as
$$
begin
  delete from Major_students where major = old.major;
  return old;
end;
$$
language 'plpgsql';


create trigger delete_major_with_total_def
  instead of delete
  on major_with_total
  for each row
execute procedure delete_major_with_total();

--Connect to default database
\c postgres;

--Drop database which you created
DROP DATABASE assignment4;
