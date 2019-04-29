create or replace force view prc_directory_vw as
select
    a.id
  , a.seqnum
  , a.encryption_type
  , a.directory_path
from
    prc_directory a
/
