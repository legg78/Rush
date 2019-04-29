create or replace force view prs_key_schema_vw as
select 
    n.id
    , n.inst_id
    , n.seqnum
from 
    prs_key_schema n
/
