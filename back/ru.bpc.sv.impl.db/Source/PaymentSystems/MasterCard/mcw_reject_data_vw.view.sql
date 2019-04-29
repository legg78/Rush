create or replace force view mcw_reject_data_vw as
select 
   id
   , reject_id
   , original_id
   , reject_type
   , process_date
   , originator_network
   , destination_network
   , scheme
   , reject_code
   , operation_type
   , assigned
   , card_number
   , arn
   , resolution_mode
   , resolution_date
   , status
   , updated_oper_id
   , reversal_oper_id
from 
  mcw_reject_data
/
 