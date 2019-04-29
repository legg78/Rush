create or replace force view amx_rejected_vw as
select
    r.id          
    , r.file_id   
    , r.inst_id    
    , r.incoming   
    , r.msg_number 
    , r.forw_inst_code
    , r.receiv_inst_code
    , r.origin_file_id  
    , r.origin_msg_id    
from amx_rejected r
/
