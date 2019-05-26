-- Creating database with assignment Number
create database assignment8;

--Connecting database
\c assignment8;


\qecho 'q.1 I have used DFS Traversal in order to check if all the nodes are accessible from each and every node in the graph. I have then finally compared the total number of nodes in the altered PC relation and nodes traversed in DFS for the altered_PC relation. If at any point the count comes to be different, then the loop breaks and graph becomes not biconnected';
--------------------------------------------------------------
-- Question 1
--------------------------------------------------------------

drop table if exists PC cascade;
create table if not exists PC(p int, c int);
insert into PC values(1, 2), (1,4), (2,3), (3,4), (3,5), (4,5), (1,3);

create or replace function DFS_traversal() returns table(node int) as $$

  begin
    drop table if exists visited;
    create table if not exists visited(visited_node int);
    drop table if exists traversed_nodes;
    create table if not exists traversed_nodes(t_node int);
    perform DFS_helper((select parent from altered_PC order by 1 limit 1));
    return query select * from traversed_nodes;
  end;
  $$language plpgsql;

create or replace function DFS_helper(nodeVal int) returns void as $$

  declare i int;

  begin
    insert into visited values(nodeVal);
    insert into traversed_nodes values(nodeVal);

    for i in (select child from altered_pc where parent = nodeVal)
    loop
      if i not in (select visited_node from visited) then
        perform DFS_helper(i);
      end if;
    end loop;
  end;
  $$ language plpgsql;

create or replace function biConnected() returns boolean as $$
  declare i int;
  begin
    if (select count(*) from PC) = 1 then
      return true;
    end if;
    drop table if exists altered_PC;
    create table altered_PC(parent int, child int);
    drop view if exists all_nodes;
    create view all_nodes as (select p as node from PC union select c as node from PC);
    for i in (select node from all_nodes)
    loop
        delete from altered_PC;
        insert into altered_PC (select p,c from PC except select p,c from PC where p = i or c = i);
        if (select count(*) from (select parent from altered_PC union select child from altered_PC) a) !=
           (select count(*) from dfs_traversal()) then
            return false;
        end if;
    end loop;
    return true;
  end;
  $$ language plpgsql;

select biConnected();
drop table if exists pc cascade;
drop table if exists altered_pc cascade;
drop table if exists visited cascade ;
drop table if exists traversed_nodes cascade ;
drop function dfs_traversal();
drop function dfs_helper(integer);
drop function biConnected();


\qecho '  '
\qecho '  '
\qecho 'q.2 Lets consider PC as a tree. I have used a simple logic. Lets consider that we have a simple tree parent(1) and its children (2,3). Now as 2 and 3 are accessible by 1, the pairs in ANC would be 1,2 and 1,3. This would make 2 and 3 from the same generation 2 as it can be accessed by 1 parent. If we consider the a node (N) which is accessed in the manner 1->2->(N), then it would have 1,N and 2,N entries in the ANC table. As tree is heirarchical structure, that means that N is generation 3. I have used this logic on all the nodes and then grouped them according to their generations ';
-------------------------------------
-- Question 2 generation pairs
-------------------------------------
DROP TABLE IF EXISTS PC cascade ;
create table PC(p int, c int);
INSERT INTO PC VALUES (1, 2);
INSERT INTO PC VALUES (1, 3);
INSERT INTO PC VALUES (2, 4);
INSERT INTO PC VALUES (2, 5);
INSERT INTO PC VALUES (3, 6);
INSERT INTO PC VALUES (3, 7);
INSERT INTO PC VALUES (4, 8);
INSERT INTO PC VALUES (4, 9);
create table if not exists ANC(a int, d int);


create or replace function ancestor_descendant() returns void as
  $$
  begin
  drop table if exists ANC cascade;
  create table if not exists ANC(a int, d int);
  insert into ANC select * from PC;
  while exists(select * from new_ANC_pairs())
    LOOP
      insert into ANC(select ancestor, descendant from new_ANC_pairs());
    end loop;
  end;
  $$ language plpgsql;

create or replace function new_ANC_pairs() returns table(ancestor int, descendant int) as $$
    select A.a, B.c from ANC A join PC B on (A.d = B.p)
  except
    select A,D from ANC
  $$ language sql;

create or replace function sameGeneration() returns table(p1 int,p2 int) as $$
begin
perform ancestor_descendant();
create view  generation_levels as (
  with nodes_and_generations as (select d as node_value, count(a) + 1 as generation from ANC group by d order by 1),
       root_and_generation as (select p as node_value, 1 as generation
                               from PC
                               where p not in (select distinct c from PC))
  select *
  from nodes_and_generations
  union
  select *
  from root_and_generation
  order by 1);
return query select a.node_value, b.node_value
from generation_levels a,
     generation_levels b
where a.generation = b.generation;
end;
$$language plpgsql;

select p1,p2 from sameGeneration();

drop function ancestor_descendant();
drop function sameGeneration();
drop function new_ANC_pairs();
drop table if exists PC cascade;
drop table if exists ANC cascade;


\qecho 'q.3 I have used basic recursion in order to calculate the total price for the pids that are not present in parts table and returned weight from parts if the variable passed to the function is present in the parts table';
-------------------------------------
-- Question 3 aggregatedWeight(p integer)
-------------------------------------
create table partSubPart (pid integer, sid integer, quantity integer);
create table parts (pid integer, weight integer);

insert into partSubPart values (1,2,4),(1,3,1),(3,4,1),(3,5,2);
insert into parts values (2,5),(4,50),(5,3);


create or replace function recursive_price(part integer) returns integer as $$
  declare price integer;
  declare child integer;
  begin
    price := 0;
    if part in(select pid from parts) then
      price:= (select weight from parts where pid = part);
      else
        for child in (select sid from partSubPart where pid = part)
          loop
            price := price + (recursive_price(child) * (select quantity from partSubPart where sid = child));
          end loop;
    end if;
    return price;
  end;
  $$language plpgsql;

create or replace function aggregatedWeight(p integer) returns integer as $$
    begin
    if p in (select pid from parts) then
      return (select weight from parts where pid = p);
    else
      return recursive_price(p);
    end if;
    end;
  $$language plpgsql;

select aggregatedWeight(1);

drop table partsubpart;
drop table parts;
drop function recursive_price(integer);
drop function aggregatedweight(integer);



\qecho 'q.4 I have created all the possible sets first and then while checking the subset condition, i have broken the arrays into temporary relations and simply checked the except between array passed in the function and the arrays in allpossibleSets';
-------------------------------------
-- Question 4 superSetsOfSet(X int[])
-------------------------------------
drop table if exists A;
drop table if exists all_sets;
create table A(a int);
create table all_sets(set_value int[]);
drop table if exists temp_table;
create table temp_table(array_val int);
drop table if exists input_array_table;
create table input_array_table(a int);


insert into A
values (1),
       (2),
       (3),
       (4);


create or replace function all_possible_sets() returns void as
$$
  declare i integer;
  declare j integer[];
  declare k integer;
begin
  drop table if exists all_sets;
  create table all_sets(set_value int[]);
  insert into all_sets values ('{}');
  drop table if exists temp_table;
  create table temp_table
  (
    array_val int
  );
  for i in select * from A
    loop
      for j in select * from all_sets
        loop
          delete from temp_table;
          for k in select * from unnest(j)
            loop
              insert into temp_table values (k);
            end loop;
          insert into temp_table values (i);
          insert into all_sets values ((select array_agg(array_val) from temp_table));
        end loop;
    end loop;
end;
$$ language plpgsql;



create or replace function superSetsOfSet(x int[]) returns table(set_value integer[]) as $$
declare
  i             integer[];
  declare j     integer;
  declare k     integer;
  declare count integer;
begin
  perform all_possible_sets();
  drop table if exists input_array_table;
  create table input_array_table
  (
    a int
  );
  drop table if exists comparison_array_table;
  create table comparison_array_table
  (
    a int
  );
  drop table if exists supersets;
  create table supersets
  (
    set_value1 integer[]
  );
  for j in select * from unnest(x)
    loop
      insert into input_array_table values (j);
    end loop;
  count := (select count(*) from input_array_table);
  if count = 0 then
    return query select * from all_sets;
  end if;
  for i in select * from all_sets
    loop
      delete from comparison_array_table;
      for k in select * from unnest(i)
        loop
          insert into comparison_array_table values (k);
        end loop;
      if not exists(select * from input_array_table except select * from comparison_array_table) then
        insert into supersets select array_agg(a) from comparison_array_table;
      end if;
    end loop;
  return query select set_value1 from supersets;
end;

  $$language plpgsql;

select superSetsOfSet(array[1]);

drop table a;
drop table all_sets;
drop table temp_table;
drop table input_array_table;
drop table comparison_array_table;
drop table supersets;
drop function all_possible_sets();
drop function supersetsofset(integer[]);



\qecho 'q.5 I have used the same logic as used in question 4. I created a relation that consists of all the possible sets and then used except between those sets and document word sets updating the tally. I the final tally >= t then return add set to final_tally_table which is returned as a result of the function';
-------------------------------------
-- Question 5 PostgreSQL program frequentSets(t int)
-------------------------------------
drop table if exists documents;
create table documents (doc text, words text[]);
insert into documents values (1, '{"A","B","C"}');
insert into documents values (2, '{"B","C","D"}');
insert into documents values (3, '{"A","E"}');
insert into documents values (4, '{"B","B","A","D"}');
insert into documents values (5, '{"E","F"}');
insert into documents values (6, '{"A","D","G"}');
insert into documents values (7, '{"C","B","A"}');
insert into documents values (8, '{"B","A"}');

create or replace function create_all_possible_sets() returns void as $$
declare i record;
  declare j text;
  declare k text[];
  declare all_words_value text;
  declare l text;

begin
  drop table if exists all_words;
  create table all_words
  (
    word text
  );
  for i in select * from documents
    loop
      for j in select * from unnest(i.words)
        loop
          if j not in (select distinct word from all_words) then
            insert into all_words values (j) ;
          end if;
        end loop;
    end loop;
  drop table if exists all_sets;
  create table all_sets(set_value text[]);
  drop table if exists temp_table;
  create table temp_table(array_val text);
  insert into all_sets values ('{}');

  for all_words_value in select * from all_words
    loop
      for k in select * from all_sets
        loop
          delete from temp_table;
          for l in select * from unnest(k)
            loop
              insert into temp_table values (l::text);
            end loop;
          insert into temp_table values (all_words_value::text);
          insert into all_sets select array(select * from temp_table);
        end loop;
    end loop;

end;
  $$ language plpgsql;

create or replace function frequentSets(t integer) returns table(set_value1 text[]) as $$
      declare i text[];
      declare j text;
      declare document_record record;
      declare l text;
      begin
          drop table if exists comparison_array_table;
          create table comparison_array_table(word_value text);
          drop table if exists document_table_word_table;
          create table document_table_word_table(document_word text);
          drop table if exists final_tally_table;
          create table final_tally_table(set_value2 text[], count integer);
          insert into final_tally_table select set_value, 0 from all_sets;
          for i in select * from all_sets
              loop
                delete from comparison_array_table;
                for j in select * from unnest(i)
                loop
                  insert into comparison_array_table values(j);
                end loop;
                for document_record in select * from documents
                  loop
                    delete from document_table_word_table;
                    for l in select * from unnest(document_record.words)
                    loop
                     insert into document_table_word_table values(l);
                    end loop;
                    if not exists(select word_value from comparison_array_table except select document_word from document_table_word_table) then
                         update final_tally_table set count = count + 1 where set_value2 = i;
                    end if;
                end loop;
              end loop;
          return query select set_value2 from final_tally_table where count >= t;
      end;
  $$ language plpgsql;

select create_all_possible_sets();
select frequentSets(3);
drop table documents;
drop table all_words;
drop table all_sets;
drop table temp_table;
drop table comparison_array_table;
drop table document_table_word_table;
drop table final_tally_table;
drop function create_all_possible_sets();
drop function frequentsets(integer);


\qecho 'q.6 Reference : https://www.hackerearth.com/practice/algorithms/graphs/topological-sort/tutorial/';
-------------------------------------
-- Question 6 topologicalSort
-------------------------------------
drop table if exists graph;
create table graph(source int, target int);
insert into graph values(5,0), (4,0), (5,2), (4,1), (2,3), (3,1);
table graph;

create or replace function topologicalSort() returns void as $$
  declare i integer;
  begin
    drop table if exists visited;
    create table visited(node_value int);
    drop table if exists sorted_graph;
    create table sorted_graph(node int, sequence int);

  for i in (select distinct source from graph order by 1 desc)
    loop
      if i not in(select node_value from visited) then
        perform topologicalSortHelper(i);
      end if;
    end loop;
  end;
  $$ language plpgsql;

create or replace function topologicalSortHelper(node_val int) returns void as
  $$
  declare i integer;
  begin
  insert into visited values(node_val);
  for i in (select target from graph where source = node_val)
    loop
      if i not in (select node_value from visited) then
        perform topologicalSortHelper(i);
      end if;
    end loop;
    insert into sorted_graph values(node_val, (select count(*) from sorted_graph) + 1);
  end;
  $$ language plpgsql;

select topologicalSort();

select node from sorted_graph order by sequence;
drop table graph;

drop table visited;

table sorted_graph;

drop function topologicalsort();

drop function topologicalsorthelper(integer);


\qecho 'q.7 Reference: https://www.youtube.com/watch?v=cplfcGZmX7I, https://en.wikipedia.org/wiki/Prim''s algorithm';
-------------------------------------
-- Question 7 Minimum Spanning Tree
-------------------------------------
drop table if exists graph;
create table graph(source int, target int, weight int);
insert into graph values(8,2,2 ),
(7,6,1 ),
(6,5,2 ),
(0,1,4 ),
(2,5,4 ),
(8,6,6 ),
(2,3,7 ),
(7,8,7 ),
(0,7,8 ),
(1,2,8 ),
(3,4,9 ),
(5,4,10),
(1,7,11),
(3,5,14);


create or replace function retrieve_children(node_value int) returns table(child int) as $$
    select distinct target from graph where source = node_value
  union
  select distinct source from graph where target = node_value;
  $$language sql;

create or replace function retrieve_weight(source_value int, target_value int) returns integer as $$
  declare weight_return_value integer;
    begin
    if (source_value, target_value) in (select source,target from graph)then
      weight_return_value:= (select weight from graph where source = source_value and target = target_value);
    end if;

    if (target_value, source_value) in (select source,target from graph)then
    weight_return_value:= (select weight from graph where source = target_value and target = source_value);
    end if;

    return weight_return_value;
    end;
  $$language plpgsql;

create or replace function prims_algorithm() returns table(parent_value1 int, child_value1 int) as $$
  declare u integer;
  declare node integer;
  declare adjacent_nodes integer;

  begin
    drop table if exists final_result;
    create table final_result(parent int, child int);
    drop table if exists prims_relations;
    create table prims_relations(node_value int, key_value int, parent_value int);
    with allnodes as (select distinct source as node1 from graph union select distinct target as node1 from graph) insert into prims_relations select node1, 99999, NULL from allnodes;
    with initial_node as (select node_value from prims_relations limit 1) update prims_relations set key_value = 0 where node_value = (select node_value from initial_node);
    while (select count(*) from prims_relations) != 0
    loop
      u := (select node_value from prims_relations where key_value = (select min(key_value) from prims_relations) limit 1);
      if (select parent_value from prims_relations where node_value = u) IS NOT NULL then
        insert into final_result select node_value, parent_value from prims_relations where node_value = u;
      end if;
      delete from prims_relations where node_value = u;
      for adjacent_nodes in (select child from retrieve_children(u))
      loop
        if adjacent_nodes in (select distinct node_value from prims_relations) then
          if (select retrieve_weight(u,adjacent_nodes)) < (select key_value from prims_relations where node_value = adjacent_nodes) then
              update prims_relations set parent_value = u where node_value = adjacent_nodes;
              update prims_relations set key_value = retrieve_weight(u,adjacent_nodes) where node_value = adjacent_nodes;
          end if;
        end if;
      end loop;
    end loop;
    return query select parent, child from final_result;
  end;
  $$language plpgsql;


select parent_value1, child_value1 from prims_algorithm();

drop table graph;

drop table final_result;

drop table prims_relations;

DROP FUNCTION prims_algorithm();


\qecho 'q.8 a Reference: http://interactivepython.org/courselib/static/pythonds/Trees/BinaryHeapImplementation.html'
-------------------------------------
-- Question 6 HeapSort
-------------------------------------

drop table if exists dataset;
create table dataset(index_value int, value_at_index int);
insert into dataset values
(1 ,5 ),
(2 ,9 ),
(3 ,11),
(4 ,14),
(5 ,18),
(6 ,19),
(7 ,21),
(8 ,33),
(9 ,17),
(10,27);


create or replace function insertion(insert_value int) returns void as $$
  begin
    insert into dataset values((select count(*) from dataset) + 1,insert_value);
    perform shiftUp((select count(*) from dataset));
  end;
  $$ language plpgsql;

create or replace function shiftUp(i bigint) returns void as $$
  declare temp_val integer;
  begin
  while (i/2) > 0
  loop
    if (select value_at_index from dataset where index_value = i) < (select value_at_index from dataset where index_value = i / 2) then
      temp_val := (select value_at_index from dataset where index_value = i / 2);
      update dataset set value_at_index = (select value_at_index from dataset where index_value = i) where index_value =  i / 2;
      update dataset set value_at_index = temp_val where index_value = i;
    end if;
    i := i/2;
  end loop;
  end;
  $$language plpgsql;

create or replace function Extract_min() returns integer as $$
    declare return_val integer;
    begin
      return_val:= (select value_at_index from dataset where index_value = 1);
      update dataset set value_at_index = NULL where index_value = 1;
      update dataset set value_at_index = (select value_at_index from dataset where index_value  = (select count(*) from dataset)) where index_value = 1;
      delete from dataset where index_value = (select count(*) from dataset);
      perform shiftDown(1);
      return return_val;
    end;
  $$ language plpgsql;

create or replace function shiftDown(i int) returns void as $$
    declare min_child integer;
      declare temp_val integer;
    begin
      while (i * 2) <= (select count(*) from dataset)
      loop
        min_child = minchild(i);
        if (select value_at_index from dataset where index_value = i) > (select value_at_index from dataset where index_value = min_child) then
          temp_val:= (select value_at_index from dataset where index_value = i);
          update dataset set value_at_index = (select value_at_index from dataset where index_value = min_child) where index_value = i;
          update dataset set value_at_index = temp_val where index_value = min_child;
        end if;
      i = min_child;
      end loop;
    end;
  $$ language plpgsql;


create or replace function minchild(i integer) returns integer as $$
  begin
    if ((i * 2) + 1) > (select count(*) from dataset) then
      return (i*2);
      else if (select value_at_index from dataset where index_value = (i * 2)) < (select value_at_index from dataset where index_value = (i * 2) + 1) then
        return (i * 2);
        else
          return (i*2) + 1;
      end if;
    end if;
    end;
  $$ language plpgsql;


drop function insertion(integer);
drop function shiftup(bigint);
drop function extract_min();
drop function minchild(integer);
drop function shiftdown(integer);


\qecho 'q.8 b https://www.programiz.com/dsa/heap-sort'
---------------------------
-- part b
---------------------------
drop table if exists dataset;
create table dataset(index_value int, value_at_index int);
insert into dataset values(1, 3),
(2, 1),
(3, 2),
(4, 7),
(5, 6),
(6, 5),
(7, 4);


create or replace function valueAtIndex(i integer) returns integer as $$
    select value_at_index from dataset where index_value = i;
  $$language sql;

create or replace function swap(index1 integer, index2 integer) returns void as $$
    declare temp_variable integer;
    begin
      temp_variable = valueatindex(index1);
      update dataset set value_at_index = valueatindex(index2) where index_value = index1;
      update dataset set value_at_index = temp_variable where index_value = index2;
    end;
  $$language plpgsql;


create or replace function heapsort() returns void as $$
    declare table_length int;
    declare least_parent int;
    declare i int;
      declare j int;
    begin
      table_length := (select count(*) from dataset)::int;
      least_parent := (table_length /2)::int;
      for i in reverse table_length..1
      loop
        perform heapify(i, table_length);
      end loop;

      for j in reverse table_length..2
      loop
        if valueatindex(1) > valueatindex(j) then
          perform swap(1, j);
          perform heapify(1,j-1);
        end if;
      end loop;
    end;
  $$language plpgsql;


create or replace function heapify(first_val int, last_val int) returns void as $$
    declare largest int;
    begin
    largest := 2*first_val;
    while largest <= last_val
      loop
        if largest < last_val then
          if valueatindex(largest) < valueatindex(largest + 1) then
            largest := largest + 1;
          end if;
        end if;

        if valueatindex(largest) > valueatindex(first_val) then
          perform swap(largest, first_val);
          first_val := largest;
          largest := 2*first_val+1;
        else
          return;
        end if;
      end loop;
    end;
  $$ language plpgsql;


select heapSort();
table dataset order by 1;


\qecho 'Question 9 Reference: https://www.youtube.com/watch?v=052VkKhIaQ4&t=611s';
----------------------------------------------
-- Question 9
----------------------------------------------

drop table if exists colorableGraph cascade;
create table if not exists colorableGraph(source int, target int);
insert into colorableGraph values(1, 2),
(2, 3),
(3, 4),
(4, 5),
(5, 1),
(1, 3),
(5, 1),
(5, 2);
drop table if exists allcolors;
create table if not exists allcolors(color text);
insert into allcolors values('red'), ('blue'), ('green');
drop table if exists coloredGraph;
  create table if not exists coloredGraph
  (
    node_value int,
    color      text
  );


create or replace function threeColorable() returns boolean as $$
declare
  node_value_check         int;
  declare color_value      text;
  declare color_viablility boolean;
begin
  drop table if exists termination;
  create table termination(terminate int);

  drop view if exists all_nodes;
  drop table if exists coloredGraph;
  create table if not exists coloredGraph
  (
    node_value int,
    color      text
  );
  create view all_nodes as (select distinct source as node
                            from colorableGraph
                            union
                            select distinct target as node
                            from colorableGraph);
  insert into coloredGraph select node, NULL from all_nodes;

  if (select count(*) from all_nodes) < 3 then
    return false;
  end if;

  for node_value_check in (select node from all_nodes order by 1)
    loop
      for color_value in (select color from allcolors)
        loop
          update coloredGraph set color = color_value where node_value = node_value_check;
          color_viablility := isGraphColorable(node_value_check);
          if color_viablility = True then
            return true;
            else
            update coloredGraph set color = null where node_value = node_value_check;
          end if;
        end loop;
      return false;
    end loop;
  return false;
end;
  $$ language plpgsql;

create or replace function isGraphColorable(colored_node int) returns boolean as
$$
declare
  child                             int;
  declare color_iteration_recursive text;
  declare no_of_colors              int;
  declare viability                 boolean;
  declare currect_child             int;
begin

  if (select count(*) from termination) = 0 then
    if exists(select node_value
              from coloredgraph
              where color IS NULL
                and node_value in (select target_val from retrieve_targets(colored_node))) then
      for child in (select target from colorableGraph where source = colored_node)
        loop
          if exists(select * from current_color_choices(child)) then

            for color_iteration_recursive in (select color_choice from current_color_choices(child))
              loop
                update coloredgraph set color = color_iteration_recursive where node_value = child;
                viability := isGraphColorable(child);
                if viability = true then
                  return true;
                else
                  update coloredgraph set color = null where node_value = child;
                end if;
              end loop;
          else
            return false;
          end if;
        end loop;
    else
      if (select count(*) from coloredgraph where color is not null) = (select count(*) from coloredgraph) then
        no_of_colors := (select count(distinct color) from coloredgraph);
        if no_of_colors = 3 then
          insert into termination values (1);
          return true;
        else
          return false;
        end if;
      end if;
      return false;
    end if;
  else
    return true;
  end if;
end;
$$ language plpgsql;




create or replace function retrieve_adjacent_nodes(node_value int) returns table(child int) as $$
    select distinct target from colorableGraph where source = node_value
  union
  select distinct source from colorableGraph where target = node_value;
  $$language sql;

create or replace function retrieve_adjacent_node_colors(node_value int) returns table(colors text) as $$
    select a.color from coloredgraph a join (select child from retrieve_adjacent_nodes(node_value)) b on (a.node_value = b.child);
  $$language sql;

create or replace function retrieve_targets(node_val int) returns table(target_val int) as $$
    select target from colorableGraph where source = node_val;
  $$language sql;

create or replace function current_color_choices(node_value int) returns table(color_choice text) as $$
    select color from allcolors except select colors from retrieve_adjacent_node_colors(node_value);
  $$ language sql;


select threeColorable();

drop table colorablegraph cascade;

drop table allcolors;

drop table termination;

drop table coloredgraph;

drop function threecolorable();

drop function isgraphcolorable(integer);

drop function retrieve_adjacent_nodes(integer);

drop function retrieve_adjacent_node_colors(integer);

drop function retrieve_targets(integer);

drop function current_color_choices(integer);


\c postgres;

--Drop database which you created
DROP DATABASE assignment8;
