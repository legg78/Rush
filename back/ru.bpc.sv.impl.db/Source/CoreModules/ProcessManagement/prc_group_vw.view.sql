create or replace force view prc_group_vw as
select
    a.id
  , a.semaphore_name
from
    prc_group a
/
