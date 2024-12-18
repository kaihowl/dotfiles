with after as (
  select *
  from startuplog
  where idx like '0'
),
before as(
  select *
  from startuplog
  where not idx like '0'
),
diffs as (
  select
    name,
    (select min(self_and_sourced) from after where name = startuplog.name) as after,
    (select min(self_and_sourced) from before where name = startuplog.name) as before
  from startuplog
  group by name
)
-- select (select sum(after) from diffs) - (select sum(before) from diffs)
-- select sum(after - before)
-- from diffs
-- where after - before > 0.5
select *, after - before as diff
from diffs
where after - before > 0.5
union
select 'sums', sum(after), sum(before), sum(after - before)
from diffs
where after - before > 0.5
order by diff
