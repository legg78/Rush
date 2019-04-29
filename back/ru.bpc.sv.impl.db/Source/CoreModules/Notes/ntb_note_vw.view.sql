create or replace force view ntb_note_vw as
select 
    n.id
  , n.entity_type
  , n.object_id
  , n.note_type
  , n.reg_date
  , n.user_id
  , n.start_date
  , n.end_date
from 
    ntb_note n
/
