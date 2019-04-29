create or replace force view rul_proc_vw as
select
    n.id
    , n.proc_name
    , n.category
from 
    rul_proc n
/
