create or replace force view vis_reject_code_vw as
select 
   id
   , reject_data_id
   , reject_code
   , description
   , field
from vis_reject_code
/
 