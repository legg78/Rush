create or replace force view opr_ui_participant_type_vw as 
select 
    p.id                  
    , p.oper_type
    , p.participant_type
from 
    opr_participant_type p
/