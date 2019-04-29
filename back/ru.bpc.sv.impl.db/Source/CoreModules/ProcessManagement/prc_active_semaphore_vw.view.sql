create or replace force view prc_active_semaphore_vw as
select
    a.name as semaphore_name
  , a.lockid
  , a.expiration
  , b.id as group_id
  , c.sid
from
    sys.dbms_lock_allocated a
  , prc_group b
  , v$lock c
where
    a.name = b.semaphore_name
and
    a.lockid = c.id1
and
    c.type = 'UL'
/
