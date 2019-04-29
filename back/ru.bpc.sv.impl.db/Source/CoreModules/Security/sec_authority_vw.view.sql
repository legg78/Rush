create or replace force view sec_authority_vw as
select
    a.id
    , a.seqnum
    , a.type
    , a.rid
from
    sec_authority a
/