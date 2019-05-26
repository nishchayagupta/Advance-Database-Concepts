-- Creating database with my initials
create database assignment1;

--Connecting database
\c assignment1;

--Table Creation Statements
create table sailor (Sid INTEGER, Sname TEXT, Rating INTEGER, Age INTEGER, primary key(Sid));
create table boat(Bid INTEGER, Bname TEXT, Color TEXT, primary key(Bid));
create table reserves (Sid INTEGER, Bid INTEGER, Day TEXT, FOREIGN KEY(Sid) REFERENCES Sailor(Sid), FOREIGN KEY (Bid) REFERENCES boat(Bid));

--Populating Tables
INSERT INTO boat VALUES	  (101, 'Interlake',     'blue'),
(102, 'Sunset',  'red'),
(103, 'Clipper', 'green'),
(104, 'Marine',  'red'),
(105, 'SunShine','blue');

INSERT INTO sailor VALUES	(22,   'Dustin',       7,      45),
(29,   'Brutus',       1,      33),
(31,   'Lubber',       8,      55),
(32,   'Andy',         8,      25),
(58,   'Rusty',        10,     35),
(64,   'Horatio',      7,      35),
(71,   'Zorba',        10,     16),
(74,   'Horatio',      9,      35),
(85,   'Art',          3,      25),
(95,   'Bob',          3,      63);

INSERT INTO reserves VALUES	(22,   101,  'Monday'),
(22,   102,  'Tuesday'),
(22,   103,  'Wednesday'),
(31,   102,  'Thursday'),
(31,   103,  'Friday'),
(31,   104,  'Saturday'),
(64,   101,  'Sunday'),
(64,   102,  'Monday'),
(74,   102,  'Saturday');


\qecho 'Q. 1 Table sailor'
table sailor;

\qecho 'Q. 1 Table boat'
table boat;

\qecho 'Q. 1 Table reserves'
table reserves;

\qecho 'Q. 2 (1) Failed Statement. This states that the value in boat ID panel should be a part of the primary key of boat table. Error Statament is ERROR: insert or update on table "reserves" violates foreign key constraint "reserves_bid_fkey" Detail: Key (bid)=(999) is not present in table "boat""'
insert into reserves values(22, 999, 'Monday');

\qecho 'Q. 2 (2) Failed Statement. This states that the value in boat ID panel should be a part of the primary key of boat table. Error Statement is "[23503] ERROR: insert or update on table "reserves" violates foreign key constraint "reserves_sid_fkey" Detail: Key (sid)=(99) is not present in table "sailor"'
insert into reserves values(99, 102, 'Monday');

\qecho 'Q. 2 (3) Passed Statament'
select * from reserves where Bid = 102;

\qecho 'Q. 2 (4) Passed Statement'
select * from boat where Bid = 102;

\qecho 'Q. 2 (5) Failed Statement insert or update on table "reserves" violates foreign key constraint "reserves_sid_fkey" Detail: Key (sid)=(100) is not present in table "sailor"'
insert into reserves values (100, 102, 'Monday');

\qecho 'Q. 2 (6) insert or update on table "reserves" violates foreign key constraint "reserves_bid_fkey" Detail: Key (bid)=(999) is not present in table "boat"'
insert into reserves values (22, 999, 'Monday');


\qecho 'Q. 3 a'
/* Query to find out the names of all the boats*/
select DISTINCT(bname) from boat;

\qecho 'Q. 3 b'
/* Query to find the Sid and Rating of each Sailor*/
select Sid, Rating from sailor;


\qecho 'Q. 3 c'
/* Query to find the sid, name and rating of all sailors whose rating is not in
the range [7, 9] */
select Sid, Sname, rating from sailor
where Rating not between 7 and 9;


\qecho 'Q. 3 d'
/* query to find bid and name of each red boat that was reserved by some
sailor whose rating is less than 9. */
select DISTINCT A.bid, B.bname from reserves A, boat B, sailor C
where B.Bid = A.bid
and b.Color = 'red'
and A.Sid in (select sid from sailor where Rating < 9);


\qecho 'Q. 3 e'
/*  Query to Find the bid and bname of each boat that was reserved by a sailor
on a Monday and by possibly a different sailor on a Tuesday */
select A.bid, B.bname from reserves A, boat B
where Day = 'Monday'
and A.sid not in(select sid from reserves where day = 'Tuesday')
and A.bid = B.bid;


\qecho 'Q. 3 f'
/* Query to Find the sid of each sailor who did not reserve any boats on a Monday,
Wednesday, or a Thursday. */
select distinct A.sid from sailor A
where A.sid not in (select sid from reserves where Day in ('Monday', 'Wednesday', 'Thursday'));


\qecho 'Q. 3 g'
/* Query to Find the bid and name of each boat that was reserved by more than
one sailor (i.e., reserved by at least two sailors) */
select distinct A.bid, B.bname from reserves A, boat B
where A.bid in (select bid from reserves group by bid having count(sid) > 1)
and B.bid = A.Bid;


\qecho 'Q. 3 h'
/* Find the pairs of bids (b1, b2) of different boats that were both reserved by a same sailor. */
select distinct A.bid as bid, B.bid as bid from reserves A, reserves B
where A.sid = B.sid
and  A.sid in (select sid from reserves group by sid having count(sid) > 1)
and A.bid != B.bid;


\qecho 'Q. 3 i'
/* Find the pairs (s, b) such that the sailor with sid s reserved the boat
with bid b, provided that the sailor s has a rating above 7 and the
color of boat b is not red */
select distinct A.sid, A.bid from reserves A, sailor B, boat C
where A.sid = B.sid
and B.sid in (select sid from sailor where rating > 7)
and A.bid in (select bid from boat where Color != 'red');


\qecho 'Q. 3 j'
/* Find the sids of sailors who reserved exactly one red boat. (You
should write this query without using the COUNT aggregate function.)*/
select distinct sid from reserves where sid not in (select distinct A.sid from reserves A, reserves B
                                                    where A.sid = B.sid and A.bid != B.bid
                                                    and A.bid in (select bid from boat where  Color = 'red')
                                                    and B.bid in (select bid from boat where  Color = 'red'))
                                                    and bid in (select bid from boat where  Color = 'red');

/*select distinct A.sid from reserves A, reserves B
where A.bid in (select bid from boat where Color = 'red')
and B.bid in (select bid from boat where Color = 'red')
and A.sid = B.sid and
A.sid not in (select distinct A.sid from reserves A, reserves B where A.bid in (select bid from boat where Color = 'red') and B.bid in (select bid from boat where Color = 'red') and A.sid = B.sid and A.bid != B.bid)
and B.sid  not in (select distinct A.sid from reserves A, reserves B where A.bid in (select bid from boat where Color = 'red') and B.bid in (select bid from boat where Color = 'red') and A.sid = B.sid and A.bid != B.bid);
*/


\qecho 'Q. 3 k'
select bid from boat where bid not in (select distinct A.bid from reserves A, reserves B where A.bid = B.bid and A.sid != B.sid);

--Connect to default database
\c postgres;

--Drop database which you created
DROP DATABASE assignment1;
