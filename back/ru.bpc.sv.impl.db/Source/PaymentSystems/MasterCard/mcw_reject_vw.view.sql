create or replace force view mcw_reject_vw as
select 
   id
   , network_id
   , inst_id
   , file_id
   , rejected_fin_id
   , rejected_file_id
   , mti
   , de024
   , de071
   , de072
   , de093
   , de094
   , de100
   , p0005
   , p0006
   , p0025
   , p0026
   , p0138
   , p0165
   , p0280
from mcw_reject
/
 